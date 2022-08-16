rm(list = ls(all = TRUE))

if(require(openxlsx)){
} else {
  install.packages("openxlsx")
  library(openxlsx)
}

if(require(stringr)){
} else {install.packages("stringr")
  library(stringr)
}

top_folder = getwd()
sec_folder = dir()

for(group in sec_folder){
  setwd(paste0(top_folder, "/" , group, "/suppl"))
  
  txt_pos_file_list = dir(pattern = "pos*")
  txt_neg_file_list = dir(pattern = "neg*")
  
  group_age = str_sub(group, 4, (nchar(group)-3))
  group_sex = "none"
  if (str_sub(group, (nchar(group)-2),(nchar(group)-2)) == 'm'){
    group_sex = "Male"
  }else if (str_sub(group, (nchar(group)-2),(nchar(group)-2)) == 'f'){
    group_sex = "Female"
  }
  group_genotype = toupper(str_sub(group, (nchar(group)-1),(nchar(group))))
  
  
  
  
  pos_out = createWorkbook()
  
  for(txt_file_name in txt_pos_file_list){
    temp_read=read.table(txt_file_name, sep = '\t', header = T)
    temp_sheet_name = strsplit(txt_file_name,".",1)[[1]][1]
    temp_sheet_name_parse = strsplit(temp_sheet_name,"_")[[1]]
    sheet_name = temp_sheet_name_parse[2:(length(temp_sheet_name_parse)-1)]
    sheet_name = toString(sheet_name)
    sheet_name = str_replace_all( sheet_name, ", ", "_")
    
    addWorksheet(pos_out, sheet_name)
    writeData(pos_out, sheet = sheet_name, x=temp_read)
    #write.xlsx(temp_read, sheetName=sheet_name, file=paste0(top_folder,"/GSEA_", group_age, "_", group_sex, "_", group_genotype, "_UP.xlsx"))
  }
  saveWorkbook(pos_out, paste0(top_folder,"/Whole_", group_age, "_", group_sex, "_", group_genotype, "_UP.xlsx"))
  
  

  
  
  
  neg_out = createWorkbook()
  
  for(txt_file_name in txt_neg_file_list){
    temp_read=read.table(txt_file_name, sep = '\t', header = T)
    temp_sheet_name = strsplit(txt_file_name,".",1)[[1]][1]
    temp_sheet_name_parse = strsplit(temp_sheet_name,"_")[[1]]
    sheet_name = temp_sheet_name_parse[2:(length(temp_sheet_name_parse)-1)]
    sheet_name = toString(sheet_name)
    sheet_name = str_replace_all( sheet_name, ", ", "_")
    
    addWorksheet(neg_out, sheet_name)
    writeData(neg_out, sheet = sheet_name, x=temp_read)
    #write.xlsx(temp_read, sheetName=sheet_name, file=paste0(top_folder,"/GSEA_", group_age, "_", group_sex, "_", group_genotype, "_DOWN.xlsx"))
  }
  saveWorkbook(neg_out, paste0(top_folder,"/Whole_", group_age, "_", group_sex, "_", group_genotype, "_DOWN.xlsx"))
}

setwd(top_folder)





# "setwd(V:/Dropbox/Dropbox (KAIST_13)/131 Chd8 RNA 분석/Raw data/RNAseq_MSigDB74_20220112_KHJ/MsigV74_P0/V74P0fht/suppl)"

