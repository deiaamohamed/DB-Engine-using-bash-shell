#!/usr/bin/env bash



create_table(){
        local db=$1
    read -r -p "Enter Table name: " table

    if [[ $table =~ " " ]]; then
        echo "Error: table name can't have a space"
        return 1
    
    elif ! is_valid "$table"; then
            echo "Error: table name must be like (student, student_t ..etc)"
            return 1
    fi

    # number of cols
    read -r -p "Enter number of cols: " cols

    if ! [[ "$cols" =~ ^[0-9]+$ ]] || (( cols <= 0 )); then
    echo "Error: columns must be a positive number"
    return 1
  fi

  col_names=()
  col_types=()
  for ((i=0; i<cols; i++));
  do
    read -r -p "Enter column name: " cname

    if [[ $cname =~ " " ]]; then
    echo "Error  col name can't have spaces"
    return 1
    fi
    if ! is_valid "$cname" ; then
        echo "Error: col name must be like (st_id, stID ...etc)"
        return 1
    fi
    read -r -p "Enter type of the Column (int/string): " ctype

    case $ctype in
    int|string)
    ;;
    *)
    echo "type must be int/string"
    return 1
    ;;
    esac

    col_names+=($cname)
    col_types+=($ctype)
    done

     echo "Columns saved:"
  for ((i=0; i<cols; i++)); do
    echo "  ${col_names[i]} : ${col_types[i]}"
  done
  #=--------------------------
    echo "Choose Primary Key column number (1-$cols): "
  select pkcol in "${col_names[@]}"; do
    if [[ -z "$pkcol" ]]; then
      echo "Invalid choice"
      return 1
    fi
    pk="$REPLY"
    break
  done
    {
    echo "cols=$cols"
    echo "pk=$pk"
    for ((i=1; i<=cols; i++)); do
      echo "col$i=${col_names[i-1]}:${col_types[i-1]}"
    done
  } > "$path/$db/$table.meta"

  : > "$path/$db/$table.data"
}

list_tables() {
  local db="$1"
  ls -1 "$path/$db" | sed 's/\.meta$//' | grep -v '\.data$'
}

    insert_into_table() {
  local db="$1"

  echo "Choose table to insert data:"
  select table in $(list_tables "$db"); do
    if [[ -z "$table" ]]; then
      echo "Invalid choice"
      return 1
    fi
    break
  done

  local meta="$path/$db/$table.meta"
  local data="$path/$db/$table.data"

  echo "Selected table: $table"
  echo "Meta file: $meta"
  echo "Data file: $data"
}

table_menu(){
   db="$1"
  

  menu=("Create Table" "List Tables" "Insert Into Table" "Drop Table" "Back")
  select choice in "${menu[@]}"; do
    case "$choice" in
      "Create Table") 
      create_table "$db"; 
      break 
      ;;
      "List Tables") 
      list_tables "$db"; 
      break 
      ;;
      "Insert Into Table") insert_into_table "$db"; 
      break ;;
      "Drop Table") 
      drop_table "$db"; 
      break ;;
      "Back") break ;;
      *) echo "Invalid choice"; break ;;
    esac
  done

  
}
