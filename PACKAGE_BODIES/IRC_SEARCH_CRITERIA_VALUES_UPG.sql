--------------------------------------------------------
--  DDL for Package Body IRC_SEARCH_CRITERIA_VALUES_UPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_SEARCH_CRITERIA_VALUES_UPG" AS
/* $Header: irscvupg.pkb 120.1 2005/10/20 20:03 gjaggava noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< update_criteria_values>-----------------------|
-- ----------------------------------------------------------------------------
procedure update_criteria_values(
	  p_process_ctrl  IN varchar2,
	  p_start_pkid  IN  number,
	  p_end_pkid  IN  number,
	  p_rows_processed  OUT  nocopy  number)
is
	cursor cur_upd_search_criteria is
	  select search_criteria_id,
                 professional_area,
                 derived_location,
	         last_update_date,
	         last_updated_by,
	         last_update_login,
	         created_by,
	         creation_date
	  from irc_search_criteria
	  where search_criteria_id between p_start_pkid and p_end_pkid
                and object_type in ('WPREF','PERSON')
                and (derived_location is not null
                     or professional_area is not null);
          --
          TYPE criteria_id_tbl  IS TABLE OF irc_search_criteria.search_criteria_id%TYPE;
          TYPE prof_area_tbl    IS TABLE OF irc_search_criteria.professional_area%TYPE;
          TYPE location_tbl     IS TABLE OF irc_search_criteria.derived_location%TYPE;
          TYPE update_date_tbl  IS TABLE OF irc_search_criteria.last_update_date%TYPE;
          TYPE updated_by_tbl   IS TABLE OF irc_search_criteria.last_updated_by%TYPE;
          TYPE update_login_tbl IS TABLE OF irc_search_criteria.last_update_login%TYPE;
          TYPE created_by_tbl   IS TABLE OF irc_search_criteria.created_by%TYPE;
          TYPE create_date_tbl  IS TABLE OF irc_search_criteria.creation_date%TYPE;
          --
          l_criteria_id   criteria_id_tbl;
          l_prof_area     prof_area_tbl;
          l_location      location_tbl;
          l_update_date   update_date_tbl;
          l_updated_by    updated_by_tbl;
          l_update_login  update_login_tbl;
          l_created_by    created_by_tbl;
          l_create_date   create_date_tbl;
begin
          OPEN cur_upd_search_criteria;
          FETCH cur_upd_search_criteria BULK COLLECT INTO
                l_criteria_id,
                l_prof_area,
                l_location,
                l_update_date,
                l_updated_by,
                l_update_login,
                l_created_by,
                l_create_date;
          p_rows_processed := l_criteria_id.COUNT;
          CLOSE cur_upd_search_criteria;
          --
          IF l_criteria_id.FIRST is not null THEN
          -- update IRC_PROF_AREA_CRITERIA_VALUES
          FORALL i IN l_criteria_id.FIRST..l_criteria_id.LAST
	      insert into irc_prof_area_criteria_values
                (prof_area_criteria_value_id
                ,search_criteria_id
                ,professional_area
                ,last_update_date
                ,last_updated_by
                ,last_update_login
                ,created_by
                ,creation_date
                ,object_version_number
                )
                select irc_prof_area_criteria_value_s.nextval,
                        l_criteria_id(i),
                        l_prof_area(i),
                        l_update_date(i),
                        l_updated_by(i),
                        l_update_login(i),
                        l_created_by(i),
                        l_create_date(i),
                        1
                from dual where l_prof_area(i) is not null;
          -- update IRC_LOCATION_CRITERIA_VALUES
          FORALL i IN l_criteria_id.FIRST..l_criteria_id.LAST
	      insert into irc_location_criteria_values
                (location_criteria_value_id
                ,search_criteria_id
                ,derived_locale
                ,last_update_date
                ,last_updated_by
                ,last_update_login
                ,created_by
                ,creation_date
                ,object_version_number
                )
                select irc_location_criteria_values_s.nextval,
                        l_criteria_id(i),
                        l_location(i),
                        l_update_date(i),
                        l_updated_by(i),
                        l_update_login(i),
                        l_created_by(i),
                        l_create_date(i),
                        1
                from dual where l_location(i) is not null;
          --
          update irc_search_criteria
	    set professional_area = null, derived_location = null
	    where search_criteria_id between p_start_pkid and p_end_pkid
                  and object_type in ('WPREF','PERSON');
          END IF;
          --
end update_criteria_values;
--
end irc_search_criteria_values_upg;

/
