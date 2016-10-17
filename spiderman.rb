class Pupil
    def initialize(year_group, class_group, last_name, first_name, gender)
        @year_group = year_group
        @class_group = class_group
        @last_name = last_name
        @first_name = first_name
        @gender = gender
    end
    def normal_name()
        @first_name + ' ' + @last_name
    end
end

Shoes.app width: 600, title: "Spider Manager" do

    @pupils = Array.new
    @before_radios = Array.new
    @emerge_radios = Array.new
    @expect_radios = Array.new
    @exceed_radios = Array.new

    def update_display()
        # re-build the strings from the radios
        @below_chn = String.new
        @emerge_chn = String.new
        @expect_chn = String.new
        @exceed_chn = String.new

        @expect_fraction = 0

        @pupils.each_index do |i|
            if @before_radios[i].checked 
                @below_chn << @pupils[i].normal_name << ', '
            end
            if @emerge_radios[i].checked 
                @emerge_chn.concat(@pupils[i].normal_name + ', ')
            end
            
            if @expect_radios[i].checked 
                @expect_fraction = @expect_fraction + 1
                @expect_chn.concat(@pupils[i].normal_name + ', ')
            end
            
            if @exceed_radios[i].checked 
                @exceed_chn.concat(@pupils[i].normal_name + ', ')
            end
        end
        # add summary stats
        percent = (100.0 * @expect_fraction / @pupils.count).round(2)
        @expect_chn.concat("#{@expect_fraction}/#{@pupils.count} or #{percent}%")
        # put the strings in the edit boxes
        @below_edit.text = @below_chn
        @emerge_edit.text = @emerge_chn
        @expect_edit.text = @expect_chn
        @exceed_edit.text = @exceed_chn
    end

    # open the file
    f = File.open("y4ellis.txt", "r")
    # loop through each record in the file, adding each record to our array.
    f.each_line { |line|
        fields = line.split("\t")
        pupil = Pupil.new(fields[0],fields[1],fields[2],fields[3],fields[4])
        @pupils.push pupil
    }

    stack_width = self.width / 2
    
    flow do
        stack width: stack_width do
            caption "Children"
            button "Update" do
                update_display
            end
            @pupils.each_index do |i|
                flow do
                    @before_radios.push radio i
                    @emerge_radios.push radio i
                    @expect_radios.push radio i, checked: true
                    @exceed_radios.push radio i
                    para @pupils[i].normal_name;
                end
            end
        end
        stack width: stack_width do
            stack do
                caption "Below Year Group"
                @below_edit = edit_box
                button "Copy (not OSX)" do
                    clipboard = @below_para.text
                end
            end
            stack do
                caption "Emerging"
                @emerge_edit = edit_box
            end
            stack do
                caption "Expected"
                @expect_edit = edit_box
            end
            stack do
                caption "Exceeding"
                @exceed_edit = edit_box
            end
        end
    end
end