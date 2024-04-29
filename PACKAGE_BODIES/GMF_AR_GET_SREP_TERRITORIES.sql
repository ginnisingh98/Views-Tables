--------------------------------------------------------
--  DDL for Package Body GMF_AR_GET_SREP_TERRITORIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AR_GET_SREP_TERRITORIES" as
/* $Header: gmfsaltb.pls 115.1 2002/11/11 00:41:48 rseshadr ship $ */
          cursor cur_ar_get_srep_territories(start_date   date,
                                             end_date     date,
                                             salesrepid   number,
                                             territoryid  number) is
             select SRT.SALESREP_ID,             SRT.TERRITORY_ID,
                    SRT.START_DATE_ACTIVE,       SRT.END_DATE_ACTIVE,
                    SRT.STATUS,                  TER.NAME,
                    TER.SEGMENT1,                TER.SEGMENT2,
                    TER.SEGMENT3,                TER.SEGMENT4,
                    TER.SEGMENT5,                TER.SEGMENT6,
                    TER.SEGMENT7,                TER.SEGMENT8,
                    TER.SEGMENT9,                TER.SEGMENT10,
                    TER.SEGMENT11,               TER.SEGMENT12,
                    TER.SEGMENT13,               TER.SEGMENT14,
                    TER.SEGMENT15,               TER.SEGMENT16,
                    TER.SEGMENT17,               TER.SEGMENT18,
                    TER.SEGMENT19,               TER.SEGMENT20,
                    SRT.ATTRIBUTE_CATEGORY,      SRT.ATTRIBUTE1,
                    SRT.ATTRIBUTE2,              SRT.ATTRIBUTE3,
                    SRT.ATTRIBUTE4,              SRT.ATTRIBUTE5,
                    SRT.ATTRIBUTE6,              SRT.ATTRIBUTE7,
                    SRT.ATTRIBUTE8,              SRT.ATTRIBUTE9,
                    SRT.ATTRIBUTE10,             SRT.ATTRIBUTE11,
                    SRT.ATTRIBUTE12,             SRT.ATTRIBUTE13,
                    SRT.ATTRIBUTE14,             SRT.ATTRIBUTE15,
                    SRT.CREATED_BY,              SRT.CREATION_DATE,
                    SRT.LAST_UPDATE_DATE,        SRT.LAST_UPDATED_BY
             from   RA_SALESREP_TERRITORIES SRT,
                    RA_TERRITORIES TER
             where  SRT.salesrep_id = nvl(salesrepid, SRT.salesrep_id)
               and  SRT.territory_id = nvl(territoryid, SRT.territory_id)
               and  TER.territory_id = SRT.territory_id
               and  SRT.last_update_date between
                                         nvl(start_date, SRT.last_update_date)
                                     and nvl(end_date, SRT.last_update_date);

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
                                           error_status       out    NOCOPY number) is

    createdby   number;
    modifiedby  number;

    begin

         if NOT cur_ar_get_srep_territories%ISOPEN then
            open cur_ar_get_srep_territories(start_date, end_date,
                                             salesrepid, territoryid);
         end if;

         fetch cur_ar_get_srep_territories
         into  salesrepid,          territoryid,       start_date_active,
               end_date_active,     status,            territory_name,
               segment1,            segment2,          segment3,
               segment4,            segment5,          segment6,
               segment7,            segment8,          segment9,
               segment10,           segment11,         segment12,
               segment13,           segment14,         segment15,
               segment16,           segment17,         segment18,
               segment19,           segment20,         attr_category,
               att1,                att2,              att3,
               att4,                att5,              att6,
               att7,                att8,              att9,
               att10,               att11,             att12,
               att13,               att14,             att15,
               createdby,           creation_date,     last_update_date,
               modifiedby;

        if cur_ar_get_srep_territories%NOTFOUND then
           error_status := 100;
           close cur_ar_get_srep_territories;
        else
           created_by := gmf_fnd_get_users.fnd_get_users(createdby);
           last_updated_by := gmf_fnd_get_users.fnd_get_users(modifiedby);
        end if;
        if row_to_fetch = 1 and cur_ar_get_srep_territories%ISOPEN then
           close cur_ar_get_srep_territories;
        end if;

      exception

          when others then
               error_status := SQLCODE;

  end AR_GET_SALESREP_TERRITORIES;
END GMF_AR_GET_SREP_TERRITORIES;

/
