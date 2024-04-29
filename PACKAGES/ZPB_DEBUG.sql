--------------------------------------------------------
--  DDL for Package ZPB_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_DEBUG" AUTHID CURRENT_USER as
/* $Header: ZPBVDBGS.pls 120.0.12010.2 2006/08/03 12:04:05 appldev noship $ */

procedure INIT(p_user          IN NUMBER,
               p_business_area IN NUMBER);

procedure SETUP(p_user          IN NUMBER,
                p_business_area IN NUMBER);

procedure STARTUP(p_user          IN NUMBER,
                  p_business_area IN NUMBER);

procedure STARTUPRO(p_user          IN NUMBER,
                    p_business_area IN NUMBER);

procedure REFRESH_BA(p_user          IN NUMBER,
                     p_business_area IN NUMBER);

procedure MDSCREEN(p_user_id     in number,
                                   p_bus_area_id in number);

procedure MDFILE(p_bus_area_id in number,
                                 p_user_id in number,
                                 p_file_dir in varchar2,
                                 p_file_name in varchar2);

procedure REBUILD_MD(p_business_area IN NUMBER);

end ZPB_DEBUG;

 

/
