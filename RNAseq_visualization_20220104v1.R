rm(list = ls(all = TRUE))
setwd(choose.dir(default = "", caption = "Select folder"))

#Packages
{
  if(require(readxl)){
  } else {install.packages(readxl)}
  
  if(require(dplyr)){
  } else {install.packages(dplyr)}
  
  if(require(janitor)){
  } else {install.packages(janitor)}
  
  if(require(tictoc)){
  } else {install.packages(tictoc)}
}

tic()

data = data.frame()

file_list = list.files(pattern = "xlsx")

for (file_name in file_list){
  
  sheet_list = excel_sheets(file_name)
  
  for (sheet_name in sheet_list){
    
    temp_data = read_excel(file_name, sheet = sheet_name)
    if (nrow(temp_data) == 0) next
    
    temp_file_name = strsplit(file_name,".",1)[[1]][1]
    
    #-># File name parcing #########################################################
    temp_file_name_parse = strsplit(temp_file_name,"_")[[1]]
    
    temp_data = bind_cols(temp_data, AGE = temp_file_name_parse[3])
    temp_data = bind_cols(temp_data, SEX = temp_file_name_parse[1])
    temp_data = bind_cols(temp_data, GENOTYPE = temp_file_name_parse[4])
    temp_data = bind_cols(temp_data, DIRECTION = temp_file_name_parse[5])
    temp_data = bind_cols(temp_data, GENESET = sheet_name)
    temp_data = bind_cols(temp_data, GROUP = paste(temp_file_name_parse[3], temp_file_name_parse[4]))
    #<-#############################################################################
    
    data = bind_rows(data, temp_data)
  }
}

data = data %>% clean_names()
save(data, file = "totaldata_total.rdata")

data = data %>% filter(fdr_q_val < 0.05)
save(data, file = "totaldata_onlySignificant.rdata")

toc()