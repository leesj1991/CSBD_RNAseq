# RNAseq_figure_20220820v1.R
# 결과에 책임지지 않습니다. Raw data와 충분히 교차검증 하고 사용하세요.
# 함께 올라와 있는 list_for_RNAseq_figure.xlsx 를 확인하고 사용하세요.

# don't touch
rm(list = ls(all = TRUE))

# EDIT PARAMETERS ##############################################################

# plot direction
# 0 (genesets in Y axis), or 1 (genesets in X axis)
reverse_plot = 1
useSample = 0


# informations of genesets

if(useSample == 0){
  
  
} else if(useSample == 1){
  
  # sample 1
  geneset_for_figure = c("ASD_RISK")
  geneset_for_figure_order = list(c("DEG UP VOINEAGU__ASD_RISK", 
                                    "COEX UP M16 VOINEAGU__ASD_RISK", 
                                    "DEG DOWN VOINEAGU__ASD_RISK", 
                                    "COEX DOWN M12 VOINEAGU__ASD_RISK", 
                                    "SFARIGENE__ASD_RISK", 
                                    "SFARIGENE(HIGH CONFIDENCE)__ASD_RISK", 
                                    "FMRPTARGETS__ASD_RISK", 
                                    "DENOVOMISS__ASD_RISK", 
                                    "DENOVOVARIANTS__ASD_RISK", 
                                    "ASD AUTISMKB__ASD_RISK"))
  
} else if(useSample == 2){
  
  # sample 2
  geneset_for_figure = c("CELL_TYPE", 
                         "SUB_CELLTYPE", 
                         "SINGLECELL_VELMESHEV")
  geneset_for_figure_order = list(c("OLIGODENDROCYTES PROGE__SUB_CELLTYPE", 
                                    "OPC__SINGLECELL_VELMESHEV", 
                                    "OLIGODENDROCYTES CAHOY__CELL_TYPE", 
                                    "OLIGODENDROCYTES ZEISEL__CELL_TYPE", 
                                    "OLIGODENDROCYTES MATURE__SUB_CELLTYPE", 
                                    "OLIGODENDROCYTES__SINGLECELL_VELMESHEV", 
                                    "ASTROCYTES CAHOY__CELL_TYPE", 
                                    "ASTROCYTES ZEISEL__CELL_TYPE", 
                                    "ASTROCYTES__SUB_CELLTYPE", 
                                    "AST-PP__SINGLECELL_VELMESHEV", 
                                    "AST-FB__SINGLECELL_VELMESHEV", 
                                    "MICROGLIA ZEISEL__CELL_TYPE", 
                                    "MICROGLIA ALBRIGHT__CELL_TYPE", 
                                    "MICROGLIA__SUB_CELLTYPE", 
                                    "MICROGLIA__SINGLECELL_VELMESHEV"))
  
} else if(useSample == 3){
  
  # sample 3
  geneset_for_figure = c("CELL_TYPE", 
                         "SUB_CELLTYPE", 
                         "SINGLECELL_VELMESHEV")
  geneset_for_figure_order = list(c("NEURONS CAHOY__CELL_TYPE", 
                                    "S1 PYRNEURONS ZEISEL__CELL_TYPE", 
                                    "CA1 PYRNEURONS ZEISEL__CELL_TYPE", 
                                    "CTX GLU LAYER1__SUB_CELLTYPE", 
                                    "L2-3__SINGLECELL_VELMESHEV", 
                                    "CTX GLU LAYER2-4__SUB_CELLTYPE", 
                                    "CTX GLU LAYER4__SUB_CELLTYPE", 
                                    "L4__SINGLECELL_VELMESHEV", 
                                    "CTX GLU LAYER5__SUB_CELLTYPE", 
                                    "L5-6__SINGLECELL_VELMESHEV", 
                                    "L5-6-CC__SINGLECELL_VELMESHEV", 
                                    "CTX GLU LAYER6__SUB_CELLTYPE", 
                                    "SUBCTX GLU__SUB_CELLTYPE", 
                                    "NEU-NRGN-I__SINGLECELL_VELMESHEV", 
                                    "NEU-NRGN-II__SINGLECELL_VELMESHEV", 
                                    "NEU-MAT__SINGLECELL_VELMESHEV", 
                                    "INTERNEURONS ZEISEL__CELL_TYPE", 
                                    "GABAPAN GAD1-2__SUB_CELLTYPE", 
                                    "GABAPRO ASCL1__SUB_CELLTYPE", 
                                    "GABAPRO DLX1-2__SUB_CELLTYPE", 
                                    "GABAPRO NKX2-1__SUB_CELLTYPE", 
                                    "GABA PVALB__SUB_CELLTYPE", 
                                    "IN-PV__SINGLECELL_VELMESHEV", 
                                    "IN-SST__SINGLECELL_VELMESHEV", 
                                    "GABA VIP__SUB_CELLTYPE", 
                                    "IN-VIP__SINGLECELL_VELMESHEV", 
                                    "GABA CALB1__SUB_CELLTYPE", 
                                    "GABA CALB2__SUB_CELLTYPE", 
                                    "GABA CCK__SUB_CELLTYPE", 
                                    "GABA NOS1__SUB_CELLTYPE", 
                                    "IN-SV2C__SINGLECELL_VELMESHEV"))
  
}

# color
# recommend 5 or 7 for step (7: darker)
color_step = 5
color_pal = "RdBu"
# color_pal = "PRGn"

################################################################################

analysis_time = format(Sys.time(), "%Y%m%d%H%M")

#setwd(choose.dir(default = "", caption = "Select folder"))

save.image(file = "figure_parameters.rdata")

#Packages
{
  if(require(readxl)){
  } else {
    install.packages("readxl")
    library(readxl)
  }
  
  if(require(dplyr)){
  } else {
    install.packages("dplyr")
    library(dplyr)
  }
  
  if(require(janitor)){
  } else {install.packages("janitor")
    library(janitor)
  }
  
  if(require(ggplot2)){
  } else {install.packages("ggplot2")
    library(ggplot2)
  }
  
  if(require(stringr)){
  } else {install.packages("stringr")
    library(stringr)
  }
  
  if(require(tictoc)){
  } else {install.packages("tictoc")
    library(tictoc)
  }
  
  if(require(RColorBrewer)){
  } else {install.packages("RColorBrewer")
    library(RColorBrewer)
  }
}

tic()

#data = data.frame()
#parsing_progress = 0;

#file_list = list.files(pattern = "^[^~]*.xlsx")

#for (file_name in file_list){

#sheet_list = excel_sheets(file_name)

#for (sheet_name in sheet_list){

#   parsing_progress = parsing_progress + 1
#   
#   temp_data = read_excel(file_name, sheet = sheet_name)
#   if (nrow(temp_data) == 0) next
#   
#   temp_file_name = strsplit(file_name,".",1)[[1]][1]
#   
#   temp_file_name_parse = strsplit(temp_file_name,"_")[[1]]
#   
#   temp_data = bind_cols(temp_data, AGE = temp_file_name_parse[AGE_ref])
#   temp_data = bind_cols(temp_data, SEX = temp_file_name_parse[SEX_ref])
#   temp_data = bind_cols(temp_data, GENOTYPE = temp_file_name_parse[GENOTYPE_ref])
#   temp_data = bind_cols(temp_data, DIRECTION = temp_file_name_parse[DIRECTION_ref])
#   temp_data = bind_cols(temp_data, GENESET = sheet_name)
#   temp_group = ""
#   for (i in 1:length(GROUP_ref)){
#     temp_group = paste(temp_group, temp_file_name_parse[GROUP_ref[i]])
#   }
#   temp_group = str_trim(temp_group, side = "left")
#   temp_data = bind_cols(temp_data, GROUP = temp_group)
#   
#   data = bind_rows(data, temp_data)
#   
#   message("Data merging | ", parsing_progress, " / ", length(file_list)*length(sheet_list))
# }
# }

#data_total = data %>% clean_names()
#data_onlySignificant = data_total %>% filter(fdr_q_val < 0.05)
#save(data_total, data_onlySignificant, file = "data.rdata")

#rm(list = ls(all = TRUE))

#defaultW = getOption("warn") 
#options(warn = -1) 

# Draw most frequently used total data #########################################
while(length(dev.list())>0) dev.off()
load("data.rdata")
data = data_total
data = bind_cols(data, combined_name = paste0(chartr("_", " ", data$name),"__",data$geneset))
load("figure_parameters.rdata")

pal = brewer.pal(n = color_step, name = color_pal)
pal = c(pal[1], pal[color_step])

analysis_time = format(Sys.time(), "%Y%m%d%H%M%S")

if(reverse_plot == 0){
  pdf(paste0("GSEA_plot_figure_total_", analysis_time, ".pdf"), paper="a4")
} else pdf(paste0("GSEA_plot_figure_total_", analysis_time, ".pdf"), paper="a4r")

{
  #variables
  group_list = unique(data$group)
  geneset_list = geneset_for_figure
  geneset_order = geneset_for_figure_order
  
  bgColorForExport = c("pink", "lightblue")
  
  tempdata = data.frame()
  
  for(choose_geneset in geneset_list){
    tempdata = bind_rows(tempdata, data %>% filter(geneset == choose_geneset))
  }
  
  #  tempdata$combined_name = chartr("_", " ", tempdata$combined_name)
  tempdata = tempdata %>% na.omit()
  
  s = ggplot(tempdata, aes(x = group, 
                           y = combined_name, 
                           size = -log2(fdr_q_val+1e-10), 
                           color = nes)) + 
    geom_point(alpha = 1) + 
    theme_light() + 
    ggtitle(str_c("Figure")) + 
    theme(panel.grid.major = element_line(size = 0.2, linetype = "solid")) +
    theme(axis.title.x = element_blank()) +
    theme(axis.title.y = element_blank()) +
    scale_y_discrete(limits = c(geneset_order[[1]])) +
    scale_x_discrete(limits = group_list) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
    #annotate("rect", xmin = 0.5, xmax = 1.5, ymin = 1, ymax = 20, alpha = 1, fill = "green") +
    #geom_rect(inherit.aes=FALSE, aes(xmin=0.5, xmax=1.5, ymin=3, ymax=4), color="transparent", fill="orange", alpha=0.3) +
    scale_size_continuous(range = c(2,5)) +
    scale_color_gradient2(midpoint=0, low=pal[2], mid="white", high=pal[1], space ="Lab" )
  
  if(reverse_plot == 1) s = s + coord_flip()
  
  print(s)
  message("Drawing | ", "figure")
}

dev.off()

rm(data)


# Draw most frequently used significant data ###################################
while(length(dev.list())>0) dev.off()
load("data.rdata")
data = data_onlySignificant
data = bind_cols(data, combined_name = paste0(chartr("_", " ", data$name),"__",data$geneset))
load("figure_parameters.rdata")

pal = brewer.pal(n = color_step, name = color_pal)
pal = c(pal[1], pal[color_step])

analysis_time = format(Sys.time(), "%Y%m%d%H%M%S")

if(reverse_plot == 0){
  pdf(paste0("GSEA_plot_figure_onlySignificant_", analysis_time, ".pdf"), paper="a4")
} else pdf(paste0("GSEA_plot_figure_onlySignificant_", analysis_time, ".pdf"), paper="a4r")

{
  #variables
  group_list = unique(data$group)
  geneset_list = geneset_for_figure
  geneset_order = geneset_for_figure_order
  
  bgColorForExport = c("pink", "lightblue")
  
  tempdata = data.frame()
  
  for(choose_geneset in geneset_list){
    tempdata = bind_rows(tempdata, data %>% filter(geneset == choose_geneset))
  }
  
  #  tempdata$combined_name = chartr("_", " ", tempdata$combined_name)
  tempdata = tempdata %>% na.omit()
  
  s = ggplot(tempdata, aes(x = group, 
                           y = combined_name, 
                           size = -log2(fdr_q_val+1e-10), 
                           color = nes)) + 
    geom_point(alpha = 1) + 
    theme_light() + 
    ggtitle(str_c("Figure")) + 
    theme(panel.grid.major = element_line(size = 0.2, linetype = "solid")) +
    theme(axis.title.x = element_blank()) +
    theme(axis.title.y = element_blank()) +
    scale_y_discrete(limits = c(geneset_order[[1]])) +
    scale_x_discrete(limits = group_list) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
    #annotate("rect", xmin = 0.5, xmax = 1.5, ymin = 1, ymax = 20, alpha = 1, fill = "green") +
    #geom_rect(inherit.aes=FALSE, aes(xmin=0.5, xmax=1.5, ymin=3, ymax=4), color="transparent", fill="orange", alpha=0.3) +
    scale_size_continuous(range = c(2,5)) +
    scale_color_gradient2(midpoint=0, low=pal[2], mid="white", high=pal[1], space ="Lab" )
  
  if(reverse_plot == 1) s = s + coord_flip()
  
  print(s)
  message("Drawing | ", "figure")
}

dev.off()

rm(data)


#options(warn = defaultW)

toc()

message("Finished")
