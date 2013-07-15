job_type :ruby, 'cd :path && :environment_variable=:environment bundle exec ruby :task'

# monday, wednesday, friday
# a few times between 3 and 7 o'clock
every '0,1,5,30,55 3-7 * * 1,3,5' do
  ruby 'mxkcd.rb'
end
