--------------------------------------------------------
--  DDL for Package PER_ZA_WSP_LOOKUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ZA_WSP_LOOKUP" AUTHID CURRENT_USER AS
/* $Header: perzawsp.pkh 120.1.12010000.1 2008/07/28 05:54:26 appldev ship $ */

Procedure wsp_lookup_values
                      (errbuf           out nocopy varchar2,
                      retcode          out nocopy number,
                      p_syncronise        in varchar2,
                      p_year              in number,
                      P_mode              in varchar2,
                      p_from_year         in number,
                      p_plan_trng_ind     in varchar2);


Procedure LOOKUP_VAL_INSERT_ROW
                     (  P_LOOKUP_TYPE             in  varchar2
                     , P_LOOKUP_CODE             in  varchar2
                     , P_ATTRIBUTE1              in  varchar2
                     , P_ATTRIBUTE2              in  varchar2
                     , P_ATTRIBUTE3              in  varchar2
                     , P_ATTRIBUTE4              in  varchar2
                     , P_ATTRIBUTE5              in  varchar2
                     , P_ATTRIBUTE6              in  varchar2
                     , P_ATTRIBUTE7              in  varchar2
                     , P_ATTRIBUTE8              in  varchar2
                     , P_ATTRIBUTE9              in  varchar2
                     , P_ATTRIBUTE10             in  varchar2
                     , P_ATTRIBUTE11             in  varchar2
                     , P_ATTRIBUTE12             in  varchar2
                     , P_ATTRIBUTE13             in  varchar2
                     , P_ATTRIBUTE14             in  varchar2
                     , P_ATTRIBUTE15             in  varchar2
                     , P_ENABLED_FLAG            in  varchar2
                     , P_MEANING                 in  varchar2
                     , P_DESCRIPTION             in  varchar2
                     , P_START_DATE_ACTIVE       in  varchar2
                     , P_END_DATE_ACTIVE         in  varchar2
                       );

Procedure create_lookup_values
                      (errbuf           out nocopy varchar2,
                      retcode           out nocopy number,
                      p_year              in number,
                      p_plan_trng_ind     in varchar2,
                      p_del_mode          in varchar2);

Procedure refresh_lookup_values
                      (errbuf           out nocopy varchar2,
                      retcode           out nocopy number,
                      p_year              in number,
                      p_plan_trng_ind     in varchar2);

Procedure copy_lookup_values
                      (errbuf               out nocopy varchar2,
                      retcode               out nocopy number,
                      p_year              in number,
                      P_from_year         in number,
                      p_plan_trng_ind     in varchar2);

Procedure copy_plan_2_trining
                      (errbuf               out nocopy varchar2,
                      retcode               out nocopy number,
                      p_year              in number,
                      P_from_year         in number);

function vs_wsp_c_yr
            (
               p_lookup_code in varchar2
               ,p_lookup_type in varchar2
             ) return varchar2;


end PER_ZA_WSP_LOOKUP;

/
