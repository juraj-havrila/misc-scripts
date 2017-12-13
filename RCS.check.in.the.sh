#!/bin/bash
#Script for faking the RCS check-in ...
#Juraj Havrila, 12.12.2017, based on not working script from A.Neufeld (23.7.2015)

for file in `cat /var/log/vicCheck | grep "not checked in" | sed 's#^Error: ##g' | sed 's# not checked in$##g'` ; do
        my_file=`basename "${file}"`
        my_dir=`dirname "${file}"`
        my_RCS_link="${my_dir}/RCS"
        my_conf_dir="/conf${my_dir}"
        my_conf_file="/conf${my_dir}/${my_file},v"

    if [ -e ${file} ]; then
        mkdir -p ${my_conf_dir}

        if [ -d ${my_RCS_link} -a ! -L ${my_RCS_link} ]; then
           #mv "${my_RCS_link}/*" "${my_conf_dir}/"
           #mv "${my_RCS_link}/.??*" "${my_conf_dir}/"
           ln -s ${my_conf_dir} ${my_RCS_link}
        elif [ ! -L ${my_RCS_link} ]; then
           ln -s ${my_conf_dir} ${my_RCS_link}
        fi

        if [ -e  ${my_conf_file} ]; then
            rcs -l "${my_dir}/${my_file}"
            ci -m'WT-1015 - automatic RCS check in (Bereinigung der nicht eingecheckten Edits)' -u "${my_dir}/${my_file}"
        else
            rcs -i -t-'WT-1015 - automatic RCS check in (Bereinigung der nicht eingecheckten Edits)' "${my_dir}/${my_file}"
            rcs -l "${my_dir}/${my_file}"
            ci -m'WT-1015 - automatic RCS check in (Bereinigung der nicht eingecheckten Edits)' -u "${my_dir}/${my_file}"
        fi
    fi
done
