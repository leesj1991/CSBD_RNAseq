# RNAseq_visualization_20220815v1.R
# 결과에 책임지지 않습니다. Raw data와 충분히 교차검증 하고 사용하세요.

# don't touch
rm(list = ls(all = TRUE))

# EDIT PARAMETERS ##############################################################

# file name parsing plan
# file name -> "1_2_3_4_5.xlsx"
AGE_ref = 2
SEX_ref = 3
GENOTYPE_ref = 4
DIRECTION_ref = 5

# grouping for dot plot
GROUP_ref = c(2, 3, 4)

# geneset number for dot plot
maximum_geneset = 30

# plot direction
# 0 (genesets in Y axis), or 1 (genesets in X axis)
reverse_plot = 1

# informations of most frequently used (interested) genesets
most_frequently_used_geneset_list = c("ASD_RISK", "CELL_TYPE", "SUB_CELLTYPE")
most_frequently_used_geneset_order = list(c("DEG UP VOINEAGU", "COEX UP M16 VOINEAGU", "DEG DOWN VOINEAGU", "COEX DOWN M12 VOINEAGU", "SFARIGENE", "SFARIGENE(HIGH CONFIDENCE)", "FMRPTARGETS", "DENOVOMISS", "DENOVOVARIANTS", "ASD AUTISMKB"), 
                                          c("NEURONS CAHOY", "S1 PYRNEURONS ZEISEL", "CA1 PYRNEURONS ZEISEL", "INTERNEURONS ZEISEL", "OLIGODENDROCYTES CAHOY", "OLIGODENDROCYTES ZEISEL", "ASTROCYTES CAHOY", "ASTROCYTES ZEISEL", "MICROGLIA ZEISEL", "MICROGLIA ALBRIGHT", "ENDOTHELIAL ZEISEL"), 
                                          c("CTX GLU LAYER1", "CTX GLU LAYER2-4", "CTX GLU LAYER4", "CTX GLU LAYER5", "CTX GLU LAYER6", "GABAPAN GAD1-2", "GABAPRO ASCL1", "GABAPRO DLX1-2", "GABAPRO NKX2-1", "GABA PVALB", "GABA CALB1", "GABA CALB2", "GABA CCK", "GABA NOS1", "GABA VIP", "OLIGODENDROCYTES PROGE", "OLIGODENDROCYTES MATURE", "ASTROCYTES", "MICROGLIA"))

# color
# recommend 5 or 7 for step (7: darker)
color_step = 5
color_pal = "RdBu"

################################################################################



analysis_time = format(Sys.time(), "%Y%m%d%H%M")

#setwd(choose.dir(default = "", caption = "Select folder"))

save.image(file = "parameters.rdata")

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

data = data.frame()
parsing_progress = 0;

file_list = list.files(pattern = "^[^~]*.xlsx")

for (file_name in file_list){
  
  sheet_list = excel_sheets(file_name)
  
  for (sheet_name in sheet_list){
    
    parsing_progress = parsing_progress + 1
    
    temp_data = read_excel(file_name, sheet = sheet_name)
    if (nrow(temp_data) == 0) next
    
    temp_file_name = strsplit(file_name,".",1)[[1]][1]
    
    temp_file_name_parse = strsplit(temp_file_name,"_")[[1]]
    
    temp_data = bind_cols(temp_data, AGE = temp_file_name_parse[AGE_ref])
    temp_data = bind_cols(temp_data, SEX = temp_file_name_parse[SEX_ref])
    temp_data = bind_cols(temp_data, GENOTYPE = temp_file_name_parse[GENOTYPE_ref])
    temp_data = bind_cols(temp_data, DIRECTION = temp_file_name_parse[DIRECTION_ref])
    temp_data = bind_cols(temp_data, GENESET = sheet_name)
    temp_group = ""
    for (i in 1:length(GROUP_ref)){
      temp_group = paste(temp_group, temp_file_name_parse[GROUP_ref[i]])
    }
    temp_group = str_trim(temp_group, side = "left")
    temp_data = bind_cols(temp_data, GROUP = temp_group)
    
    data = bind_rows(data, temp_data)
    
    message("Data merging | ", parsing_progress, " / ", length(file_list)*length(sheet_list))
  }
}

data_total = data %>% clean_names()
data_onlySignificant = data_total %>% filter(fdr_q_val < 0.05)
save(data_total, data_onlySignificant, file = "data.rdata")

rm(list = ls(all = TRUE))

defaultW = getOption("warn") 
options(warn = -1) 

# Draw total data ##############################################################
while(length(dev.list())>0) dev.off()
load("data.rdata")
data = data_total
load("parameters.rdata")

pal = brewer.pal(n = color_step, name = color_pal)
pal = c(pal[1], pal[color_step])

if(reverse_plot == 0){
  pdf(paste0("GSEA_plot_total_", analysis_time, ".pdf"), paper="a4")
} else pdf(paste0("GSEA_plot_total_", analysis_time, ".pdf"), paper="a4r")

{
  #variables
  group_list = unique(data$group)
  geneset_list = unique(data$geneset)
  direction_list = rev(unique(data$direction))
  bgColorForExport = c("pink", "lightblue")
  plot_order = 0;
  
  for(choose_geneset in geneset_list){
    for(change_direction in direction_list){
      for(arrby in group_list){
        plot_order = plot_order+1
        arrby_data = data %>% filter(group == arrby & geneset == choose_geneset)
        if(nrow(arrby_data) == 0) next
        tempdata = data[which(data$name %in% arrby_data$name),] %>% filter(geneset == choose_geneset)
        
        plot_number = min(maximum_geneset, nrow(arrby_data))
        
        if(change_direction == direction_list[1]){
          tempdata = tempdata %>% arrange(desc(nes))
        }else if(change_direction == direction_list[2]){
          tempdata = tempdata %>% arrange(nes)
        }
        
        tempdata$name = chartr("_", " ", tempdata$name)
        tempdata$name = str_wrap(tempdata$name, width = 30)
        tempdata = tempdata %>% na.omit()
        geneset_order = (tempdata %>% filter(group==arrby) %>% select(name))[1:plot_number,]
        
        s = ggplot(tempdata, aes(x = group, 
                                 y = name, 
                                 size = -log2(fdr_q_val+1e-10), 
                                 color = nes)) + 
          geom_point(alpha = 1) + 
          theme_light() + 
          ggtitle(str_c("Geneset: ", choose_geneset, 
                        "\nChange direction: ", change_direction, 
                        "\nArranged by: ", arrby)) + 
          theme(panel.grid.major = element_line(size = 0.2, linetype = "solid", color = bgColorForExport[change_direction])) +
          theme(axis.title.x = element_blank()) +
          theme(axis.title.y = element_blank()) +
          scale_y_discrete(limits = rev(geneset_order)) +
          scale_x_discrete(limits = group_list) +
          theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
          geom_vline(xintercept = arrby, linetype = 'dashed', color='grey50', size = 0.2) +
          #annotate("rect", xmin = 0.5, xmax = 1.5, ymin = 1, ymax = 20, alpha = 1, fill = "green") +
          #geom_rect(inherit.aes=FALSE, aes(xmin=0.5, xmax=1.5, ymin=3, ymax=4), color="transparent", fill="orange", alpha=0.3) +
          scale_size_continuous(range = c(2,5)) +
          scale_color_gradient2(midpoint=0, low=pal[2], mid="white", high=pal[1], space ="Lab" )
        
        if(reverse_plot == 1) s = s + coord_flip()
        
        print(s)
        message("Drawing | ", "Geneset: ", choose_geneset, " / Change direction: ", change_direction, " / Arranged by: ", arrby)
      }
    }
  }
  
  dev.off()
}

rm(data)

# Draw only significant data ###################################################
while(length(dev.list())>0) dev.off()
load("data.rdata")
data = data_onlySignificant
load("parameters.rdata")

pal = brewer.pal(n = color_step, name = color_pal)
pal = c(pal[1], pal[color_step])

if(reverse_plot == 0){
  pdf(paste0("GSEA_plot_onlySignificant_", analysis_time, ".pdf"), paper="a4")
} else pdf(paste0("GSEA_plot_onlySignificant_", analysis_time, ".pdf"), paper="a4r")

{
  #variables
  group_list = unique(data$group)
  geneset_list = unique(data$geneset)
  direction_list = rev(unique(data$direction))
  bgColorForExport = c("pink", "lightblue")
  
  for(choose_geneset in geneset_list){
    for(change_direction in direction_list){
      for(arrby in group_list){
        
        arrby_data = data %>% filter(group == arrby & geneset == choose_geneset)
        if(nrow(arrby_data) == 0) next
        tempdata = data[which(data$name %in% arrby_data$name),] %>% filter(geneset == choose_geneset)
        
        plot_number = min(maximum_geneset, nrow(arrby_data))
        
        if(change_direction == direction_list[1]){
          tempdata = tempdata %>% arrange(desc(nes))
        }else if(change_direction == direction_list[2]){
          tempdata = tempdata %>% arrange(nes)
        }
        
        tempdata$name = chartr("_", " ", tempdata$name)
        tempdata$name = str_wrap(tempdata$name, width = 30)
        tempdata = tempdata %>% na.omit()
        geneset_order = (tempdata %>% filter(group==arrby) %>% select(name))[1:plot_number,]
        
        s = ggplot(tempdata, aes(x = group, 
                                 y = name, 
                                 size = -log2(fdr_q_val+1e-10), 
                                 color = nes)) + 
          geom_point(alpha = 1) + 
          theme_light() + 
          ggtitle(str_c("Geneset: ", choose_geneset, 
                        "\nChange direction: ", change_direction, 
                        "\nArranged by: ", arrby)) + 
          theme(panel.grid.major = element_line(size = 0.2, linetype = "solid", color = bgColorForExport[change_direction])) +
          theme(axis.title.x = element_blank()) +
          theme(axis.title.y = element_blank()) +
          scale_y_discrete(limits = rev(geneset_order)) +
          scale_x_discrete(limits = group_list) +
          theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
          geom_vline(xintercept = arrby, linetype = 'dashed', color='grey50', size = 0.2) +
          #annotate("rect", xmin = 0.5, xmax = 1.5, ymin = 1, ymax = 20, alpha = 1, fill = "green") +
          #geom_rect(inherit.aes=FALSE, aes(xmin=0.5, xmax=1.5, ymin=3, ymax=4), color="transparent", fill="orange", alpha=0.3) +
          scale_size_continuous(range = c(2,5)) +
          scale_color_gradient2(midpoint=0, low=pal[2], mid="white", high=pal[1], space ="Lab" )
        
        if(reverse_plot == 1) s = s + coord_flip()
        
        print(s)
        message("Drawing | ", "Geneset: ", choose_geneset, " / Change direction: ", change_direction, " / Arranged by: ", arrby)
      }
    }
  }
  
  dev.off()
}

rm(data)

# Draw most frequently used total data #########################################
while(length(dev.list())>0) dev.off()
load("data.rdata")
data = data_total
load("parameters.rdata")

pal = brewer.pal(n = color_step, name = color_pal)
pal = c(pal[1], pal[color_step])

if(reverse_plot == 0){
  pdf(paste0("GSEA_plot_most_frequently_used_total_", analysis_time, ".pdf"), paper="a4")
} else pdf(paste0("GSEA_plot_most_frequently_used_total_", analysis_time, ".pdf"), paper="a4r")

{
  #variables
  group_list = unique(data$group)
  geneset_list = most_frequently_used_geneset_list
  geneset_order = most_frequently_used_geneset_order
  
  bgColorForExport = c("pink", "lightblue")
  
  for(choose_geneset in geneset_list){
    
    tempdata = data %>% filter(geneset == choose_geneset)
    
    tempdata$name = chartr("_", " ", tempdata$name)
    tempdata$name = str_wrap(tempdata$name, width = 30)
    tempdata = tempdata %>% na.omit()
    
    s = ggplot(tempdata, aes(x = group, 
                             y = name, 
                             size = -log2(fdr_q_val+1e-10), 
                             color = nes)) + 
      geom_point(alpha = 1) + 
      theme_light() + 
      ggtitle(str_c("Geneset: ", choose_geneset)) + 
      theme(panel.grid.major = element_line(size = 0.2, linetype = "solid")) +
      theme(axis.title.x = element_blank()) +
      theme(axis.title.y = element_blank()) +
      scale_y_discrete(limits = geneset_order[[which(geneset_list == choose_geneset)]]) +
      scale_x_discrete(limits = group_list) +
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
      #annotate("rect", xmin = 0.5, xmax = 1.5, ymin = 1, ymax = 20, alpha = 1, fill = "green") +
      #geom_rect(inherit.aes=FALSE, aes(xmin=0.5, xmax=1.5, ymin=3, ymax=4), color="transparent", fill="orange", alpha=0.3) +
      scale_size_continuous(range = c(2,5)) +
      scale_color_gradient2(midpoint=0, low=pal[2], mid="white", high=pal[1], space ="Lab" )
    
    if(reverse_plot == 1) s = s + coord_flip()
    
    print(s)
    message("Drawing | ", "Geneset: ", choose_geneset)
  }
  
  dev.off()
}

rm(data)

# Draw most frequently used significant data ###################################
while(length(dev.list())>0) dev.off()
load("data.rdata")
data = data_onlySignificant
load("parameters.rdata")

pal = brewer.pal(n = color_step, name = color_pal)
pal = c(pal[1], pal[color_step])

if(reverse_plot == 0){
  pdf(paste0("GSEA_plot_most_frequently_used_significant_", analysis_time, ".pdf"), paper="a4")
} else pdf(paste0("GSEA_plot_most_frequently_used_significant_", analysis_time, ".pdf"), paper="a4r")

{
  #variables
  group_list = unique(data$group)
  geneset_list = most_frequently_used_geneset_list
  geneset_order = most_frequently_used_geneset_order
  
  bgColorForExport = c("pink", "lightblue")
  
  for(choose_geneset in geneset_list){
    
    tempdata = data %>% filter(geneset == choose_geneset)
    
    tempdata$name = chartr("_", " ", tempdata$name)
    tempdata$name = str_wrap(tempdata$name, width = 30)
    tempdata = tempdata %>% na.omit()
    
    s = ggplot(tempdata, aes(x = group, 
                             y = name, 
                             size = -log2(fdr_q_val+1e-10), 
                             color = nes)) + 
      geom_point(alpha = 1) + 
      theme_light() + 
      ggtitle(str_c("Geneset: ", choose_geneset)) + 
      theme(panel.grid.major = element_line(size = 0.2, linetype = "solid")) +
      theme(axis.title.x = element_blank()) +
      theme(axis.title.y = element_blank()) +
      scale_y_discrete(limits = geneset_order[[which(geneset_list == choose_geneset)]]) +
      scale_x_discrete(limits = group_list) +
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
      #annotate("rect", xmin = 0.5, xmax = 1.5, ymin = 1, ymax = 20, alpha = 1, fill = "green") +
      #geom_rect(inherit.aes=FALSE, aes(xmin=0.5, xmax=1.5, ymin=3, ymax=4), color="transparent", fill="orange", alpha=0.3) +
      scale_size_continuous(range = c(2,5)) +
      scale_color_gradient2(midpoint=0, low=pal[2], mid="white", high=pal[1], space ="Lab" )
    
    if(reverse_plot == 1) s = s + coord_flip()
    
    print(s)
    message("Drawing | ", "Geneset: ", choose_geneset)
  }
  
  dev.off()
}

options(warn = defaultW)

toc()

message("Finished")
