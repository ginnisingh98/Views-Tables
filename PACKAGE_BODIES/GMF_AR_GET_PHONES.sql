--------------------------------------------------------
--  DDL for Package Body GMF_AR_GET_PHONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AR_GET_PHONES" as
/* $Header: gmfcuphb.pls 120.1 2005/09/08 09:24:08 sschinch noship $ */

    procedure AR_GET_PHONES (cust_id            in out NOCOPY number,
                             addressid          in out NOCOPY number,
                             contactid          in out NOCOPY number,
                             phoneid            in out NOCOPY number,
                             phonetype          in out NOCOPY varchar2,
                             start_date         in out NOCOPY date,
                             end_date           in out NOCOPY date,
                             phone_number       out    NOCOPY varchar2,
                             area_code          out    NOCOPY varchar2,
                             extension          out    NOCOPY varchar2,
                             primary_flag       out    NOCOPY varchar2,
                             phstatus           in out NOCOPY varchar2,
                             attr_category      out    NOCOPY varchar2,
                             att1               out    NOCOPY varchar2,
                             att2               out    NOCOPY varchar2,
                             att3               out    NOCOPY varchar2,
                             att4               out    NOCOPY varchar2,
                             att5               out    NOCOPY varchar2,
                             att6               out    NOCOPY varchar2,
                             att7               out    NOCOPY varchar2,
                             att8               out    NOCOPY varchar2,
                             att9               out    NOCOPY varchar2,
                             att10              out    NOCOPY varchar2,
                             att11              out    NOCOPY varchar2,
                             att12              out    NOCOPY varchar2,
                             att13              out    NOCOPY varchar2,
                             att14              out    NOCOPY varchar2,
                             att15              out    NOCOPY varchar2,
                             created_by         out    NOCOPY number,
                             creation_date      out    NOCOPY date,
                             last_update_date   out    NOCOPY date,
                             last_updated_by    out    NOCOPY number,
                             row_to_fetch       in out NOCOPY number,
                             error_status       out    NOCOPY number) is
    begin
     NULL;
  end AR_GET_PHONES;
END GMF_AR_GET_PHONES;

/
