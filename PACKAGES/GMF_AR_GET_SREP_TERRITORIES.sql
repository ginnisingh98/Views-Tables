--------------------------------------------------------
--  DDL for Package GMF_AR_GET_SREP_TERRITORIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AR_GET_SREP_TERRITORIES" AUTHID CURRENT_USER as
/* $Header: gmfsalts.pls 115.1 2002/11/11 00:41:57 rseshadr ship $ */
    procedure AR_GET_SALESREP_TERRITORIES (salesrepid         in out NOCOPY number,
                                           territoryid        in out NOCOPY number,
                                           start_date         in out NOCOPY date,
                                           end_date           in out NOCOPY date,
                                           start_date_active  out    NOCOPY date,
                                           end_date_active    out    NOCOPY date,
                                           status             out    NOCOPY varchar2,
                                           territory_name     out    NOCOPY varchar2,
                                           segment1           out    NOCOPY varchar2,
                                           segment2           out    NOCOPY varchar2,
                                           segment3           out    NOCOPY varchar2,
                                           segment4           out    NOCOPY varchar2,
                                           segment5           out    NOCOPY varchar2,
                                           segment6           out    NOCOPY varchar2,
                                           segment7           out    NOCOPY varchar2,
                                           segment8           out    NOCOPY varchar2,
                                           segment9           out    NOCOPY varchar2,
                                           segment10          out    NOCOPY varchar2,
                                           segment11          out    NOCOPY varchar2,
                                           segment12          out    NOCOPY varchar2,
                                           segment13          out    NOCOPY varchar2,
                                           segment14          out    NOCOPY varchar2,
                                           segment15          out    NOCOPY varchar2,
                                           segment16          out    NOCOPY varchar2,
                                           segment17          out    NOCOPY varchar2,
                                           segment18          out    NOCOPY varchar2,
                                           segment19          out    NOCOPY varchar2,
                                           segment20          out    NOCOPY varchar2,
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
                                           created_by         out    NOCOPY varchar2,
                                           creation_date      out    NOCOPY date,
                                           last_update_date   out    NOCOPY date,
                                           last_updated_by    out    NOCOPY varchar2,
                                           row_to_fetch       in out NOCOPY number,
                                           error_status       out    NOCOPY number);

END GMF_AR_GET_SREP_TERRITORIES;

 

/
