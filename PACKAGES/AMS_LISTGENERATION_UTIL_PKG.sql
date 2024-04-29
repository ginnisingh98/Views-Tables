--------------------------------------------------------
--  DDL for Package AMS_LISTGENERATION_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LISTGENERATION_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: amsvlgus.pls 120.3 2006/02/23 01:35:46 bmuthukr noship $*/

cancelListGen Exception ;

cursor get_status_code(p_list_header_id Number) is
  select status_code
  from ams_list_headers_all
  where list_header_id = p_list_header_id;

type spl_preview_count is record
(s_no         number,
 sp_query     varchar2(32767),
 prv_count    number);

type spl_preview_count_tbl is table of spl_preview_count index by binary_integer;

split_preview_count_tbl spl_preview_count_tbl;

PROCEDURE cancel_list_gen(p_list_header_id in NUMBER,
                          p_remote_gen in VARCHAR2,
                          p_remote_gen_list in VARCHAR2,
                          p_database_link in VARCHAR2,
                          x_msg_count OUT NOCOPY NUMBER,
                          x_msg_data OUT NOCOPY VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2);

Procedure Delete_List_entries(p_list_header_id in NUMBER,
                 x_msg_count OUT NOCOPY NUMBER,
                 x_msg_data OUT NOCOPY VARCHAR2,
		 x_return_status out nocopy VARCHAR2);

Procedure Update_list_header(p_list_header_id in Number,
--			     p_msg_count IN NUMBER,
--                           p_msg_data IN VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2);

Function getWFItemStatus(p_list_header_id in Number) return VARCHAR2;

Function isListCancelling(p_list_header_id in Number) return VARCHAR2;
/*PROCEDURE START_CTRL_GRP_PROCESS
             (p_list_header_id  in  number,
              p_log_flag           in  varchar2 := 'Y'  ,-- DEFAULT 'Y',
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2) ;*/

PROCEDURE START_CTRL_GRP_PROCESS
             (p_list_header_id  in  number);

/*PROCEDURE CANCEL_CTRL_GRP_PROCESS
             (p_list_header_id  in  number,
              p_log_flag           in  varchar2  := 'Y',
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2);*/
PROCEDURE CANCEL_CTRL_GRP_PROCESS
             (p_list_header_id  in  number);

--Procedure added by bmuthukr for CR#4886329
procedure get_split_preview_count(p_split_preview_count_tbl IN OUT NOCOPY AMS_LISTGENERATION_UTIL_PKG.split_preview_count_tbl%type,
                                  p_list_header_id          IN NUMBER,
				  x_return_status           OUT NOCOPY VARCHAR2,
                                  x_msg_count               OUT NOCOPY NUMBER,
                                  x_msg_data                OUT NOCOPY VARCHAR2);

END AMS_LISTGENERATION_UTIL_PKG;

 

/
