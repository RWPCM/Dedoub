#!/usr/bin/env ruby

class Tab_rep < Array
    def merge_dups
        self.sort! { | e, f | (e[0][:size] <=> f[0][:size]) * 10 + (e[0][:total_nb_of_files] <=> f[0][:total_nb_of_files]) }
        arr = Array.new
        arr[0] = self[0]
        if self.length >=2
            n = self.length - 1
            for i in 1..n
                if arr[-1][0] == self[i][0]
                    arr[-1] << self[i][1]
                else
                    arr << self[i]
                end
            end
        end
        return arr
    end
end

a = Tab_rep.new([[{:size=>1340, :total_nb_of_files=>10}, :Rep12], [{:size=>1500, :total_nb_of_files=>10}, :Rep2], [{:size=>1340, :total_nb_of_files=>8}, :Rep3], [{:size=>1600, :total_nb_of_files=>15}, :Rep11], [{:size=>1340, :total_nb_of_files=>13}, :Rep5], [{:size=>1340, :total_nb_of_files=>30}, :Rep6], [{:size=>1600, :total_nb_of_files=>15}, :Rep10], [{:size=>1340, :total_nb_of_files=>12}, :Rep8], [{:size=>1340, :total_nb_of_files=>10}, :Rep9], [{:size=>1600, :total_nb_of_files=>15}, :Rep7], [{:size=>1340, :total_nb_of_files=>10}, :Rep4], [{:size=>1340, :total_nb_of_files=>3}, :Rep1]])



puts a.merge_dups.to_s