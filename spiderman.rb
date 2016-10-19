class PupilArray
    def initialize()
        @pupils = Array.new
    end
    def read_from_file(filename)
        # open the file
        debug filename
        f = File.open(filename, "r")
        # loop through each record in the file, adding each record to our array.
        f.each_line { |line|
            pupil = Pupil.new
            pupil.read(line)
            @pupils.push pupil
        }
    end
    def all()
        @pupils
    end
end

class Pupil
    def read(line)
        fields = line.split("\t")
        @year_group = fields[0]
        @class_group = fields[1]
        @last_name = fields[2]
        @first_name = fields[3]
        @gender = fields[4]
        # expect at least 4 fields, if there's a 5th...
        if fields.length > 4
            @assessment = fields[5]
        else
            @assessment = :expected
        end
    end
    def normal_name()
        @first_name + ' ' + @last_name
    end
    def get_assessment()
        @assessment
    end
    def set_assessment(value)
        @assessment = value
    end
end

Shoes.app width: 600, title: "Spider Manager" do

    @pupils = PupilArray.new

    @below_radios = Array.new
    @emerge_radios = Array.new
    @expect_radios = Array.new
    @exceed_radios = Array.new

    def update_model()
        # there might be a per radio way to do this on click
        @pupils.all.each_index do |i|
            if @below_radios[i].checked 
                @pupils.all[i].set_assessment(:below)
            end
            if @emerge_radios[i].checked 
                @pupils.all[i].set_assessment(:emerging)
            end
            
            if @expect_radios[i].checked 
                @pupils.all[i].set_assessment(:expected)
            end
            
            if @exceed_radios[i].checked 
                @pupils.all[i].set_assessment(:exceeding)
            end
        end
    end

    def update_view()
        # re-build the radios
        @below_radios = Array.new
        @emerge_radios = Array.new
        @expect_radios = Array.new
        @exceed_radios = Array.new
        @radio_stack.clear
        @pupils.all.each_index do |i|
            @radio_stack.append do
                flow do
                    r = radio i
                    @below_radios.push r
                    r = radio i
                    @emerge_radios.push r
                    r = radio i
                    @expect_radios.push r
                    r = radio i
                    @exceed_radios.push r
                    para @pupils.all[i].normal_name
                end
            end
        end
        
        # re-build the copiable strings from the model
        @below_chn = String.new
        @emerge_chn = String.new
        @expect_chn = String.new
        @exceed_chn = String.new

        @expect_fraction = 0

        @pupils.all.each_index do |i|
            if @pupils.all[i].get_assessment == :below 
                @below_chn << @pupils.all[i].normal_name << ', '
            end
            if @pupils.all[i].get_assessment == :emerging
                @emerge_chn.concat(@pupils.all[i].normal_name + ', ')
            end
            
            if @pupils.all[i].get_assessment == :expected 
                @expect_fraction = @expect_fraction + 1
                @expect_chn.concat(@pupils.all[i].normal_name + ', ')
            end
            
            if @pupils.all[i].get_assessment == :exceeding
                @exceed_chn.concat(@pupils.all[i].normal_name + ', ')
            end
        end
        # add summary stats
        percent = (100.0 * @expect_fraction / @pupils.all.count).round(2)
        @expect_chn.concat("#{@expect_fraction}/#{@pupils.all.count} or #{percent}%")
        # put the strings in the edit boxes
        @below_edit.text = @below_chn
        @emerge_edit.text = @emerge_chn
        @expect_edit.text = @expect_chn
        @exceed_edit.text = @exceed_chn
    end

    stack_width = self.width / 2
    
    flow do
        stack width: stack_width do
            caption "Children"
            flow do
                button "Open..." do
                    filename = ask_open_file()
                    @pupils.read_from_file(filename)
                    update_view
                end
                button "Update" do
                    update_model
                    update_view
                end
            end
            @radio_stack = stack # placeholder for radio buttons
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