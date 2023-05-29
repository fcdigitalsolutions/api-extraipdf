import os as dir 

_cPathArq   =  "C:/GPS/Meus_Projetos/Projetos_FullStack_Atuais/Extrai_PDF_Python/api-extraipdf/dados/"

for diretorio, subpastas, arquivos in dir.walk(_cPathArq):
    for arquivo in arquivos:
     #   print(dir.path.join(diretorio, arquivo))
        print(arquivo)