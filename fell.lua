--fell
--as rain or a mountain
--sequencer/installation/kalimba
--speed of each note set in time
--notes play when they cross a pressed key
time = {73,97,109,137,163,181,199,227,233,211,193,173,151,127,103,83} --primes
pace = 5 --global tempo. ms per pulse
note = {77,71,67,64,60,57,48,52,33,47,55,59,62,65,69,72} --midi notes
length = 4 --sustain time before midi_note_off
lowV = 40 --lowest velocity (velocity randomized for each note)
highV = 100 --highest velocity
counter = {}
seq = {}
noteOn = {}
l = {}
j = {}
pulse = 1

function tick()

  for i=1,16 do
    j[i] = pulse%time[i] --checks if pulse is a multiple of time[i]
    if j[i] == 0 then
      if noteOn[i] == true then --countdown to note_off
        if l[i] == 0 then
          midi_note_off(note[i],0,1)
          noteOn[i] = false
        else
          l[i] = l[i]-1
        end
      end
      for k=1,16 do --set grid to match sequence
        grid_led(i,k,(seq[i][k]*5))
      end
      counter[i]=(counter[i]%16)+1 --step the sequence
      grid_led(i,counter[i],15) --light up the playhead
      if seq[i][counter[i]] == 1 then --if this step is active, play a note
        vel = math.random(lowV,highV)
        midi_note_on(note[i],vel,1)
        noteOn[i] = true
        l[i] = length-1
      end
    end
  end
  pulse = pulse + 1
  grid_refresh()
end

function grid(x,y,z)
  print (x,y,z)
  if z == 1 then
    seq[x][y] = 1 - seq[x][y] --toggles key/sequence state
    for i=1,16 do --grid lighting code duplicated from above for responsiveness to key press
      grid_led((counter[i]),i,0)
      for k=1,16 do
        grid_led(i,k,(seq[i][k]*5))
      end
      grid_led(i,counter[i],15)
    end
    grid_refresh()
  end
end

for i=1,16 do --initializing the tables
  counter[i] = 1
  noteOn[i] = false
  l[i] = length
  seq[i] = {}
  for j=1,16 do
    seq[i][j] = 0
  end
  seq[i][16] = 1
end

m = metro.new(tick,pace)
grid_led_all(0)
grid_refresh()
