--------------------------------------------------------
--  DDL for Package Body PER_KR_EXTRA_ORG_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_KR_EXTRA_ORG_RULES" as
/* $Header: pekrhroi.pkb 120.1 2005/09/21 05:03:21 viagarwa noship $ */
    procedure check_yea_entry_dates(
        P_ORGANIZATION_ID                in number,
        P_ORG_INFORMATION_CONTEXT        in varchar2,
        P_ORG_INFORMATION3               in varchar2,
        P_ORG_INFORMATION4               in varchar2)
    is
        l_end_date      date;
        l_cutoff_date   date;

    begin
        if (P_ORG_INFORMATION_CONTEXT = 'KR_YEA_ENTRY_PERIOD_BG' )  then

            l_end_date    := fnd_date.canonical_to_date(P_ORG_INFORMATION3);
            l_cutoff_date := fnd_date.canonical_to_date(P_ORG_INFORMATION4);
            if l_cutoff_date is null then
                l_cutoff_date := to_date('31.12.4712','DD.MM.YYYY');
            end if;

            if l_end_date > l_cutoff_date then
                fnd_message.set_name('PAY', 'PAY_KR_YEA_UDATE_LT_EDATE');
                fnd_message.raise_error;
            end if;
        end if;

        if (P_ORG_INFORMATION_CONTEXT = 'KR_YEA_ENTRY_PERIOD_ORG' )  then

            l_end_date    := fnd_date.canonical_to_date(P_ORG_INFORMATION3);
            l_cutoff_date := fnd_date.canonical_to_date(P_ORG_INFORMATION4);
            if l_cutoff_date is null then
                l_cutoff_date := to_date('31.12.4712','DD.MM.YYYY');
            end if;

            if l_end_date > l_cutoff_date then
                fnd_message.set_name('PAY', 'PAY_KR_YEA_UDATE_LT_EDATE_ORG');
                fnd_message.raise_error;
            end if;
        end if;

    end check_yea_entry_dates;

end per_kr_extra_org_rules;

/
