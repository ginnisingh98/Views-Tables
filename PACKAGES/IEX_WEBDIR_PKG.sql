--------------------------------------------------------
--  DDL for Package IEX_WEBDIR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_WEBDIR_PKG" AUTHID CURRENT_USER AS
/* $Header: iexvwbas.pls 120.2 2005/07/06 19:16:11 jypark noship $ */


  TYPE assist_rec_type IS RECORD
               ( assist_id                    NUMBER,
                 program_id                   NUMBER,
                 object_version_number        NUMBER,
                 last_update_date             DATE,
                 last_updated_by              NUMBER,
                 creation_date                DATE,
                 created_by                   NUMBER,
                 last_update_login            NUMBER,
                 assistance_type              VARCHAR2(15),
                 location                     VARCHAR2(254)
                 -- by jypark 12/26/2000 org_id                       NUMBER
               );

  TYPE web_assist_rec_type IS RECORD
               ( web_assist_id                NUMBER,
                 proxy_host                   VARCHAR2(240),
                 proxy_port                   VARCHAR2(240),
                 enabled_flag                 VARCHAR2(1),
                 program_id                   NUMBER,
                 creation_date                DATE,
                 last_update_date             DATE,
                 created_by                   NUMBER,
                 last_updated_by              NUMBER,
                 last_update_login            NUMBER,
                 assist_id                    NUMBER,
                 object_version_number        NUMBER,
                 -- by jypark 12/26/2000 org_id                       NUMBER,
                 attribute_category           VARCHAR2(30),
                 attribute1                   VARCHAR2(150),
                 attribute2                   VARCHAR2(150),
                 attribute3                   VARCHAR2(150),
                 attribute4                   VARCHAR2(150),
                 attribute5                   VARCHAR2(150),
                 attribute6                   VARCHAR2(150),
                 attribute7                   VARCHAR2(150),
                 attribute8                   VARCHAR2(150),
                 attribute9                   VARCHAR2(150),
                 attribute10                  VARCHAR2(150),
                 attribute11                  VARCHAR2(150),
                 attribute12                  VARCHAR2(150),
                 attribute13                  VARCHAR2(150),
                 attribute14                  VARCHAR2(150),
                 attribute15                  VARCHAR2(150)
               );

  TYPE web_search_rec_type IS RECORD
               ( search_id                    NUMBER,
                 enabled_flag                 VARCHAR2(1),
                 program_id                   NUMBER,
                 object_version_number        NUMBER,
                 creation_date                DATE,
                 last_update_date             DATE,
                 created_by                   NUMBER,
                 last_updated_by              NUMBER,
                 last_update_login            NUMBER,
                 search_url                   VARCHAR2(240),
                 cgi_server                   VARCHAR2(240),
                 next_page_ident              VARCHAR2(240),
                 max_nbr_pages                NUMBER,
                 web_assist_id                NUMBER,
                 directory_assist_flag        VARCHAR2(1), -- add by jypark 12/26/2000 for new requirement
                 -- by jypark 12/26/2000 org_id        NUMBER,
                 attribute_category           VARCHAR2(30),
                 attribute1                   VARCHAR2(150),
                 attribute2                   VARCHAR2(150),
                 attribute3                   VARCHAR2(150),
                 attribute4                   VARCHAR2(150),
                 attribute5                   VARCHAR2(150),
                 attribute6                   VARCHAR2(150),
                 attribute7                   VARCHAR2(150),
                 attribute8                   VARCHAR2(150),
                 attribute9                   VARCHAR2(150),
                 attribute10                  VARCHAR2(150),
                 attribute11                  VARCHAR2(150),
                 attribute12                  VARCHAR2(150),
                 attribute13                  VARCHAR2(150),
                 attribute14                  VARCHAR2(150),
                 attribute15                  VARCHAR2(150)
              );

  TYPE query_string_rec_type IS RECORD
               ( query_string_id              NUMBER,
                 program_id                   NUMBER,
                 object_version_number        NUMBER,
                 creation_date                DATE,
                 last_update_date             DATE,
                 created_by                   NUMBER,
                 last_updated_by              NUMBER,
                 last_update_login            NUMBER,
                 switch_separator             VARCHAR2(240),
                 url_separator                VARCHAR2(240),
                 header_const                 VARCHAR2(240),
                 search_id                    NUMBER,
                 trailer_const                VARCHAR2(240),
                 enabled_flag                 VARCHAR2(1),
                 -- by jypark 12/26/2000 org_id                       NUMBER,
                 attribute_category           VARCHAR2(30),
                 attribute1                   VARCHAR2(150),
                 attribute2                   VARCHAR2(150),
                 attribute3                   VARCHAR2(150),
                 attribute4                   VARCHAR2(150),
                 attribute5                   VARCHAR2(150),
                 attribute6                   VARCHAR2(150),
                 attribute7                   VARCHAR2(150),
                 attribute8                   VARCHAR2(150),
                 attribute9                   VARCHAR2(150),
                 attribute10                  VARCHAR2(150),
                 attribute11                  VARCHAR2(150),
                 attribute12                  VARCHAR2(150),
                 attribute13                  VARCHAR2(150),
                 attribute14                  VARCHAR2(150),
                 attribute15                  VARCHAR2(150)
              );


  PROCEDURE Create_WebAssist(
                      p_api_version IN NUMBER,
                      p_init_msg_list IN VARCHAR2,
                      p_commit IN VARCHAR2,
                      p_validation_level IN NUMBER,
                      x_return_status OUT NOCOPY VARCHAR2,
                      x_msg_count OUT NOCOPY NUMBER,
                      x_msg_data OUT NOCOPY VARCHAR2,
                      p_assist_rec IN assist_rec_type,
                      p_web_assist_rec IN web_assist_rec_type,
                      p_web_search_rec IN web_search_rec_type,
                      p_query_string_rec IN query_string_rec_type
                      );

  PROCEDURE Lock_WebAssist(
                      p_api_version IN NUMBER,
                      p_init_msg_list IN VARCHAR2,
                      p_commit IN VARCHAR2,
                      p_validation_level IN NUMBER,
                      x_return_status OUT NOCOPY VARCHAR2,
                      x_msg_count OUT NOCOPY NUMBER,
                      x_msg_data OUT NOCOPY VARCHAR2,
                      p_assist_rec IN assist_rec_type,
                      p_web_assist_rec IN web_assist_rec_type,
                      p_web_search_rec IN web_search_rec_type,
                      p_query_string_rec IN query_string_rec_type
                      );

  PROCEDURE Update_WebAssist(
                      p_api_version IN NUMBER,
                      p_init_msg_list IN VARCHAR2,
                      p_commit IN VARCHAR2,
                      p_validation_level IN NUMBER,
                      x_return_status OUT NOCOPY VARCHAR2,
                      x_msg_count OUT NOCOPY NUMBER,
                      x_msg_data OUT NOCOPY VARCHAR2,
                      p_assist_rec IN assist_rec_type,
                      p_web_assist_rec IN web_assist_rec_type,
                      p_web_search_rec IN web_search_rec_type,
                      p_query_string_rec IN query_string_rec_type
                      );

  PROCEDURE Delete_WebAssist(
                      p_api_version IN NUMBER,
                      p_init_msg_list IN VARCHAR2,
                      p_commit IN VARCHAR2,
                      p_validation_level IN NUMBER,
                      x_return_status OUT NOCOPY VARCHAR2,
                      x_msg_count OUT NOCOPY NUMBER,
                      x_msg_data OUT NOCOPY VARCHAR2,
                      p_assist_rec IN assist_rec_type,
                      p_web_assist_rec IN web_assist_rec_type,
                      p_web_search_rec IN web_search_rec_type,
                      p_query_string_rec IN query_string_rec_type
                      );


END;

 

/
