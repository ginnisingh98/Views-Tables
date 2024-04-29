--------------------------------------------------------
--  DDL for Package INV_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_UTILITY_PVT" AUTHID CURRENT_USER AS
  /* $Header: INVFUTLS.pls 115.0 2002/12/13 18:26:22 ajohnson noship $ */


  /*=======================================================
   API name    : get_log_dir
   Type        : Private
   Function    : Get path name defined from utl_file_dir
  =========================================================*/
  PROCEDURE get_log_dir(
    x_return_status OUT NOCOPY VARCHAR2
  , x_msg_count     OUT NOCOPY NUMBER
  , x_msg_data      OUT NOCOPY VARCHAR2
  , x_log_dir       OUT NOCOPY VARCHAR2
  );

  /*=======================================================
   API name    : write_debug_file
   Type        : Private
   Function    : Write message to logfile.
  ========================================================*/
  PROCEDURE write_debug_file(line IN VARCHAR2);

  /*========================================================
   API name    : open_debug_file
   Type        : Private
   Function    : Open the logfile for writing log message.
  =========================================================*/
  PROCEDURE open_debug_file(
    p_path_name     IN            VARCHAR2
  , p_file_name     IN            VARCHAR2
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  );

  /*========================================================
   API name    : close_debug_file
   Type        : Private
   Function    : Close the logfile
  =========================================================*/
  PROCEDURE close_debug_file;

END inv_utility_pvt;

 

/
