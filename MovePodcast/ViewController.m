//
//  ViewController.m
//  MoveFiles
//
//  Created by Jose Antonio Vazquez Mingorance on 20/10/15.
//  Copyright (c) 2015 Jose Vazquez. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
}

//
// Comprobacion si el archivo a tratar es directorio
// En casi afirmativo devuelve "SI"

- (BOOL)onlyFolders:(int)i filelist:(NSArray *)filelist url:(NSURL *)url filemgr:(NSFileManager *)filemgr {
    
    NSString *path = [[url path] stringByAppendingPathComponent:[filelist objectAtIndex: i]];
    
    BOOL isDir = NO;
    
    [filemgr fileExistsAtPath:path isDirectory:(&isDir)];
    
    return isDir;
    
}


// Obtenemos la fecha formateada
- (NSString *)formatFecha:(NSDictionary *)attrs {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM"];
    
    NSDate *date = (NSDate*)[attrs objectForKey: NSFileCreationDate];
    
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    return formattedDateString;
}

// Creación de directorios
-(void)createDirectory:(NSString *)directoryName atFilePath:(NSString *)filePath
{
    NSString *filePathAndDirectory = [filePath stringByAppendingPathComponent:directoryName];
    
    NSFileManager *filemgr;
    
    filemgr = [NSFileManager defaultManager];
    
    [filemgr createDirectoryAtPath:filePathAndDirectory  withIntermediateDirectories:NO attributes: nil error:nil];
    
}

// Movimiento de los archivos
- (void)moveFile:(NSString *)str newFile:(NSString *)newFile {
    
    
    NSFileManager *filemgr;
    
    filemgr = [NSFileManager defaultManager];
    
    NSURL *oldArchive= [NSURL fileURLWithPath:str];
    
    NSURL *newArchive = [NSURL fileURLWithPath:newFile];
    
    [filemgr moveItemAtURL: oldArchive toURL: newArchive error: nil];
}

// Subdirectorios
- (void)recorreSubdirectorios:(int)i filelist:(NSArray *)filelist url:(NSURL *)url {
    
    NSArray *filelist1;
    NSString *ruta;
    NSFileManager *filemgr;
    
    filemgr = [NSFileManager defaultManager];
    
    long count1;
    int j;
    
    ruta = [[url path] stringByAppendingPathComponent:[filelist objectAtIndex: i]];
    // NSLog(@"%@",ruta);
    
    
    filelist1 = [filemgr contentsOfDirectoryAtPath: ruta  error: nil];
    
    // Convertimos de NSString a NSURL
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:ruta];
    
    
    count1 = [filelist1 count];
    
    for (j = 0; j < count1; j++)
    {
        BOOL isDir;
        
        // Vemos los que solo son archivos
        isDir = [self onlyFolders:j filelist:filelist1 url:fileURL filemgr:filemgr];
        if (!(isDir))
        {
            NSLog (@"%@", [filelist1 objectAtIndex: j]);
            // Obtener el año y mes de creacion
            
            NSFileManager* fm = [NSFileManager defaultManager];
            
            NSString *file = [filelist1 objectAtIndex: j];
            NSString *path = ruta;
            NSString *sepr = @"/";
            NSString *exts = file.pathExtension;
            NSString *str = [NSString stringWithFormat: @"%@%@%@", path,sepr,file];
            
            NSDictionary* attrs = [fm attributesOfItemAtPath:str error:nil];
            
            if (attrs != nil && ![exts  isEqual: @""]) {
                
                NSString *YearMoth = [self formatFecha:attrs];
                //NSLog(@"formattedDateString: %@", YearMoth);
                
                 // Creacion de la carpeta
                [self createDirectory:YearMoth atFilePath:path];
                
                // Movimiento del archivo a su carpeta correspondiente
                NSString *newFile = [NSString stringWithFormat: @"%@%@%@%@%@", path,sepr,YearMoth,sepr,file];
              
                [self moveFile:str newFile:newFile];
                
            }
            else {
                NSLog(@"Not found");
            }
            
           
        }
    }
}

- (void)finProceso: (NSString*) cadena  {
    
    NSAlert* msgBox = [[NSAlert alloc] init] ;
    
    [msgBox setMessageText: cadena];
    
    [msgBox addButtonWithTitle: @"OK"];
    
    [msgBox runModal];
    
    NSLog(@"Fin del proceso");
}

// Abre panel de seleccion de carpeta
- (IBAction)AbreDirectorio:(id)sender {
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        
        for (NSURL *url in [panel URLs]) {
            
            NSFileManager *filemgr;
            NSArray *filelist;
            
            long count;
            int i;
            
            filemgr = [NSFileManager defaultManager];
            
            filelist = [filemgr contentsOfDirectoryAtPath: [url path] error: nil];
            
            count = [filelist count];
            
            // Todos los archivos
            for (i = 0; i < count; i++)
            {
                BOOL isDir;
                isDir = [self onlyFolders:i filelist:filelist url:url filemgr:filemgr];
                
                // Comprobacion de solo los directorios
                if (isDir){
                    
                    [self recorreSubdirectorios:i filelist:filelist url:url];
                    
                }
                
            }
        }
        
        [self finProceso:(@"Proceso finalizado")];
    }
}

// Boton de salida de la aplicacion
- (IBAction)exit:(id)sender {
    
    [self finProceso:(@"Saliendo de la aplicación")];
    
    [NSApp terminate:self];
    
}

@end

