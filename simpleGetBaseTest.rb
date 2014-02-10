require 'watir-webdriver'
require 'io/console'

module GetBaseModule
    
    def gotoLeads
        puts 'Go to Lead page'
        self.getApp.div(:id => 'topbar').li(:id=> 'nav-item-leads').wait_until_present
        self.getApp.div(:id => 'topbar').li(:id=> 'nav-item-leads').click
    end
    
    def gotoSettings
        puts 'Go to Settings'
        self.getApp.i(:class => 'icon-cogs').when_present.click
        if self.getApp.li(:class => 'settings').wait_until_present
           self.getApp.li(:class => 'settings').click 
        end
        if self.getApp.h1.wait_until_present
            return true
        else
            puts "Failed!! Settings page has not been loaded"
            return false
        end
    end
    
    def changeStatusName(oldName, newName)
        if gotoSettings
            self.getApp.div(:id => 'sidebar').li(:class => 'leads').click
            self.getApp.a(:href => '#lead-status').when_present.click
            self.getApp.div(:id => 'lead-status').wait_until_present
            p = self.getApp.div(:id => 'lead-status').h4(:text => oldName).parent.parent
            p.div(:class => "btn-toolbar").button(:class => "btn btn-mini edit").click
            t = self.getApp.text_field(:xpath => "//descendant::input[@value='" + oldName + "']").parent.parent.parent
            self.getApp.text_field(:xpath => "//descendant::input[@value='" + oldName + "']").set newName
            t.button(:class => 'btn btn-primary save').click
            if self.getApp.div(:id => 'lead-status').h4(:text => newName)
                return true
            else
                puts "Failed!! The status name has not been changed"
                return false
            end
        else
            return false
        end
    end
    
    def createLead(leadData={})
        
        gotoLeads
        self.getApp.span(:id => 'selection').when_present.click
                
        #fill the form
        self.getApp.text_field(:id => 'lead-first-name').when_present.set leadData[:firstName]
        self.getApp.text_field(:id => 'lead-last-name').when_present.set leadData[:lastName]
        self.getApp.a(:class => 'save btn btn-large btn-primary').click 
        self.getApp.a(:class => 'btn btn-mini detail-edit').wait_until_present
        #get lead id
        leadId = self.getApp.execute_script("return document.getElementsByClassName('btn btn-mini detail-edit')[0].getAttribute('href');")
        leadId = leadId.split('/')[2]
        puts "Created Lead id= " + leadId
        return leadId
    end
    
    def checkLeadStatus(leadId, status, gotoLeadsFirst)
        
        if gotoLeadsFirst
            gotoLeads
            sleep 3
            self.getApp.a(:xpath => "//descendant::a[@href='/leads/" + leadId + "']").when_present.click
        end
        
        
        self.getApp.span(:class => 'lead-status').wait_until_present
        if self.getApp.span(:class => 'lead-status').text == status
            return true
        else
            puts "Failed!! Lead status is not: " + status
            return false
        end
    end    
    
    def openGetBaseApp(login, pass)
        
        self.getApp.goto 'app.futuresimple.com'
        self.getApp.text_field(:id => 'user_email').when_present.set login
        self.getApp.text_field(:id => 'user_password').when_present.set pass
        btnLogin = self.getApp.button(:class => "btn btn-large btn-primary")
        if btnLogin.exists?
            btnLogin.click
        end
    end  
end

class ChromeBrowser
    include GetBaseModule
    
    def initialize
        @getBaseApp = Watir::Browser.new :chrome
        #@getBaseApp.driver.manage.timeouts.implicit_wait = 5
    end
    
    def getApp
        return @getBaseApp
    end
end

puts "To start the getBase application please provide your credentials first"
puts "E-mail:" 
STDOUT.flush  
login = gets.chomp  
puts "Password:" 
password = STDIN.noecho(&:gets).chomp  

app = ChromeBrowser.new
app.openGetBaseApp(login, password)

leadData = { :firstName => "JOHN", :lastName => "RAMBO"}

lead = app.createLead(leadData)
if app.checkLeadStatus(lead, "New", false)
    if app.changeStatusName("New", "Sleeping")
        app.checkLeadStatus(lead, "Sleeping", true)
    end
end

#TODO :)
#clear data and close app after test execution
