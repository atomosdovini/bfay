require "open3"
require "dotenv"
require "libnotify"
require "json"
require 'gtk3'

# create a new window
window = Gtk::Window.new

# set the window title
window.set_title("ask to bfay")

# create a grid layout
grid = Gtk::Grid.new
# create an entry field for the name
name_entry = Gtk::Entry.new
# create a submit button
submit_button = Gtk::Button.new(:label => "Submit")
# add the widgets to the grid layout
grid.attach(name_entry, 1, 0, 1, 1)
grid.attach(submit_button, 0, 2, 2, 1)
# add the grid layout to the window
window.add(grid)
# show the window
window.show_all

# attach a callback function to the submit button
submit_button.signal_connect "clicked" do
    # get the user's input
    name = name_entry.text
  
    # save the input to a file
    File.open("input.txt", "w") do |f|
      f.puts "Name: #{name}"
    end
  
    # show a message to the user
    message_dialog = Gtk::MessageDialog.new(:parent => window, :flags => :destroy_with_parent, :type => :info, :buttons_type => :close, :message => "Input saved successfully")
    message_dialog.run
    message_dialog.destroy

    Dotenv.load

    prompt = name_entry.text
    model = "text-davinci-002"
    max_tokens = 64
    api_key = ENV["api_key"]

    # Set up the command to send a request to the GPT-3 API using the openai Python package
    command = "python3 -c 'import openai; openai.api_key = \"#{api_key}\"; "
    command += "completion = openai.Completion.create(engine=\"#{model}\", prompt=\"#{prompt}\", max_tokens=#{max_tokens}); "
    command += "print(completion)'"

    # Run the command and retrieve the output
    output, _status = Open3.capture2(command)

    # Print the output (the response from the GPT-3 API)
    puts output
    json = JSON.parse(output)
    text = json["choices"][0]["text"]
    # create a new notification
    notification = Libnotify.new
    # set the summary text for the notification
    notification.summary = "bfay diz"
    # set the body text for the notification
    notification.body = "#{text}"
    # set the urgency level for the notification
    # (low, normal, critical)
    notification.urgency = :critical

    # set the timeout for the notification
    # (in milliseconds)
    notification.timeout = 500

    # show the notification
    notification.show!
  end

# run the GTK+ event loop
Gtk.main





