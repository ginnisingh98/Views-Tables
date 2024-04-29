--------------------------------------------------------
--  DDL for Package Body IGS_PE_IDENTIFY_DUPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_IDENTIFY_DUPS" AS
/* $Header: IGSPE03B.pls 120.0 2005/06/01 15:41:13 appldev noship $ */

/*
  ||  Created By : prabhat.patel
  ||  Created On : 09-OCT-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || ssaleem          10-nov-2004     3877652 - Handling Inactive Persons
  || ssawhney         25-jun-2003     3005910 - Devry MCS issue, making ADDRESS and PERSONIDGROUP changes
  || npalanis         26-may-2003     2853529 - Implementation of bind variables for family details build
  || npalanis         22-APR-2003     BUG:2832980
  ||                                  variable l_location_id is removed as it is not used anywhere
  ||  pkpatel         10-OCT-2002     Bug NO: 2603065
  ||                                  REPLACE single quote with double quotes to form proper SELECT clause when any of the
  ||                                  parameter value contains an Apostrophe in procedure form_dup_whereclause
  ||  pkpatel         10-JUN-2003     Bug 2940810
  ||                                  PKM SQL Bind issue(Modified literal to Bind variables)
  ||                                  Stubbed the find_duplicates procedures
  ||  gmaheswa        8-OCT-2003      Bug 3146324
  ||                                  Match Criteria Sets Enhancement
  ||  (reverse chronological order - newest change first)
  */

  PROCEDURE find_dup_main(
    ERRBUF OUT NOCOPY VARCHAR2,
    RETCODE OUT NOCOPY VARCHAR2,
    x_match_set_id IN NUMBER,
    x_report_requested IN VARCHAR2)
  IS
  BEGIN
    NULL;
  END find_dup_main;


   PROCEDURE find_duplicates (
    x_errbuf IN OUT NOCOPY VARCHAR2,
    x_retcode IN OUT NOCOPY VARCHAR2,
    x_match_set_id IN NUMBER)
  IS
  BEGIN
    NULL;
  END find_duplicates;


  PROCEDURE find_duplicates_p(
        x_errbuf IN OUT NOCOPY VARCHAR2,
        x_retcode IN OUT NOCOPY VARCHAR2,
        x_match_set_id IN NUMBER,
        x_batch_id IN NUMBER)
  IS
  BEGIN
    NULL;
  END find_duplicates_p;

  PROCEDURE find_duplicates_pp(
        x_errbuf IN OUT NOCOPY VARCHAR2,
        x_retcode IN OUT NOCOPY VARCHAR2,
        x_match_set_id IN NUMBER,
        x_batch_id IN NUMBER,
        x_person_id_type IN VARCHAR2)
  IS
BEGIN
    NULL;
END find_duplicates_pp;

PROCEDURE find_duplicates_pa(
        x_errbuf IN OUT NOCOPY VARCHAR2,
        x_retcode IN OUT NOCOPY VARCHAR2,
        x_match_set_id IN NUMBER,
        x_batch_id IN NUMBER,
        x_addr_type IN VARCHAR2)
  IS
 BEGIN
        NULL;
 END find_duplicates_pa;

  PROCEDURE find_duplicates_ppa(
    x_errbuf IN OUT NOCOPY VARCHAR2,
    x_retcode IN OUT NOCOPY VARCHAR2,
    x_match_set_id IN NUMBER,
    x_batch_id IN NUMBER,
    x_addr_type IN VARCHAR2,
    x_person_id_type IN VARCHAR2)
  IS
  BEGIN
    NULL;
  END find_duplicates_ppa;


  PROCEDURE form_dup_whereclause(
    x_errbuf IN OUT NOCOPY VARCHAR2 ,
    x_retcode IN OUT NOCOPY VARCHAR2 ,
    x_match_set_id IN NUMBER,
    x_match_category IN VARCHAR2,
    x_view_name IN VARCHAR2,
    x_person_id IN NUMBER,
    x_surname IN VARCHAR2,
    x_given_names IN VARCHAR2,
    x_api_person_id IN VARCHAR2,
    x_pref_alternate_id IN VARCHAR2,
    x_person_id_type IN VARCHAR2,
    x_birth_dt IN DATE,
    x_sex IN VARCHAR2,
    x_ethnic_origin IN VARCHAR2,
    x_addr_type IN VARCHAR2,
    x_addr_line_1 IN VARCHAR2,
    x_addr_line_2 IN VARCHAR2,
    x_addr_line_3 IN VARCHAR2,
    x_addr_line_4 IN VARCHAR2,
    x_city IN VARCHAR2,
    x_state IN VARCHAR2,
    x_province IN VARCHAR2,
    x_county IN VARCHAR2,
    x_country IN VARCHAR2,
    x_postcode IN VARCHAR2,
    x_select_clause IN OUT NOCOPY VARCHAR2

    )
  IS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 09-OCT-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ssawhney        25-jun-2003     3005910 - Devry MCS issue, making ADDRESS and PERSONIDGROUP changes
  ||                                  Addr_type and person_id_type to be appended with relevant fields
  ||                                  in Partial Match, for Drop if null=N, addr_type not to be appended for Addr_line1 and country
  ||  pkpatel         10-OCT-2002     Bug NO: 2593455
  ||                                  REPLACE single quote with double quotes to form proper SELECT clause when any of the
  ||                                  parameter value contains an Apostrophe
  ||                                  Added the code for data element ALTERNATE_ID
  ||  pkpatel         10-JUN-2003     Bug 2940810
  ||                                  PKM SQL Bind issue(Modified literal to Bind variables)
  ||  pkpatel         21-AUG-2003     Bug 3103195 (Removed Address line 1 from ANDing with other address element for partial match.
  ||                                  Added DISTINCT clause for selecting the person id)
  ||  asbala          23-SEP-2003     Bug 3130316, Duplicate Person Matching Performance Improvements
  ||  gmaheswa        1-OCT-2003      Bug 3146324, Match Criteria Sets Enhancement
  ||  asbala          28-nov-2003     Removed data element 'SURNAME_5_CHAR'
  ||  gmaheswa	      24-jan-2005     Bug: 3882788 Added the start_dt <> end_dt or end_dt is null check for person_id_type
  ||  (reverse chronological order - newest change first)
  */

    l_surname			igs_pe_dup_matches_ppa_v.surname%TYPE;
    l_given_names		igs_pe_dup_matches_ppa_v.given_names%TYPE;
    l_given_name_1_char		igs_pe_dup_matches_ppa_v.given_name_1_char%TYPE;
    l_api_person_id		igs_pe_dup_matches_ppa_v.api_person_id%TYPE;
    l_pref_alternate_id		igs_pe_dup_matches_ppa_v.pref_alternate_id%TYPE;
    l_person_id_type		igs_pe_dup_matches_ppa_v.person_id_type%TYPE;
    l_sex			igs_pe_dup_matches_ppa_v.sex%TYPE;
    l_ethnic_origin		igs_pe_dup_matches_ppa_v.ethnic_origin%TYPE;
    l_addr_type			igs_pe_dup_matches_ppa_v.addr_type%TYPE;
    l_addr_line_1		igs_pe_dup_matches_ppa_v.addr_line_1%TYPE;
    l_conct_address_lines	igs_pe_dup_matches_prim_ppa_v.conct_address_lines%TYPE;
    l_addr_line_2		igs_pe_dup_matches_ppa_v.addr_line_2%TYPE;
    l_addr_line_3		igs_pe_dup_matches_ppa_v.addr_line_3%TYPE;
    l_addr_line_4		igs_pe_dup_matches_ppa_v.addr_line_4%TYPE;
    l_city			igs_pe_dup_matches_ppa_v.city%TYPE;
    l_state			igs_pe_dup_matches_ppa_v.state%TYPE;
    l_province			igs_pe_dup_matches_ppa_v.province%TYPE;
    l_county			igs_pe_dup_matches_ppa_v.county%TYPE;
    l_country			igs_pe_dup_matches_ppa_v.country%TYPE;
    l_postcode			igs_pe_dup_matches_ppa_v.postcode%TYPE;


   l_SelectClause   VARCHAR2(2000);

   l_default_sql_text  VARCHAR2(2000);
   l_final_sql_text    VARCHAR2(32000);
   l_partial_if_null   BOOLEAN := FALSE;
   l_partial_clause    BOOLEAN := FALSE;

  BEGIN

    l_surname          := UPPER(x_surname);
    l_given_names      := UPPER(x_given_names);
    l_api_person_id     :=UPPER(x_api_person_id);
    l_pref_alternate_id :=UPPER(x_pref_alternate_id);
    l_person_id_type   := UPPER(x_person_id_type);
    l_sex              := UPPER(x_sex);
    l_ethnic_origin    := UPPER(x_ethnic_origin);
    l_addr_type        := UPPER(x_addr_type);
    l_addr_line_1      := UPPER(x_addr_line_1);
    l_addr_line_2      := UPPER(x_addr_line_2);
    l_addr_line_3      := UPPER(x_addr_line_3);
    l_addr_line_4      := UPPER(x_addr_line_4);
    l_city             := UPPER(x_city);
    l_state            := UPPER(x_state);
    l_province         := UPPER(x_province);
    l_county           := UPPER(x_county);
    l_country          := UPPER(x_country);
    l_postcode         := UPPER(x_postcode);

    l_given_name_1_char := UPPER(SUBSTR(l_given_names, 1, 1));

    l_conct_address_lines := l_addr_line_1||l_addr_line_2||l_addr_line_3||l_addr_line_4;


   fnd_dsql.init;
   fnd_dsql.add_text('SELECT DISTINCT person_id FROM '|| x_view_name||' WHERE  UPPER(surname) = ');
   fnd_dsql.add_bind(l_surname);
   fnd_dsql.add_text(' AND UPPER(SUBSTR(given_names,1,1)) = ');
   fnd_dsql.add_bind(l_given_name_1_char);

   IF Igs_Pe_Identify_Dups.g_exclude_inactive_ind = 'Y' THEN
     fnd_dsql.add_text(' AND STATUS = ');
     fnd_dsql.add_bind('A');
   END IF;


   IF x_person_id IS NOT NULL THEN
      fnd_dsql.add_text(' AND person_id <> ');
      fnd_dsql.add_bind(x_person_id);
   END IF;

   -- Form the default select statement
  l_default_sql_text := fnd_dsql.get_text(FALSE);

  -- Form the match category is 'E', that exact append the where clause with 'AND'
 IF x_match_category = 'E' THEN
  FOR i IN 1..g_matchset_exact.COUNT LOOP

        -- append the where clause with given name
    IF g_matchset_exact(i).data_element = 'GIVEN_NAME'  THEN
      IF X_GIVEN_NAMES IS NULL THEN
        IF g_partial_if_null  = 'Y' THEN
          l_partial_if_null := TRUE;
          EXIT;
        ELSIF g_matchset_exact(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' AND given_names IS NULL');
        END IF;
      ELSE
        fnd_dsql.add_text(' AND UPPER(given_names) = ');
        fnd_dsql.add_bind(l_given_names);
      END IF;
      -- append the where clause with preferred alternate id
    ELSIF g_matchset_exact(i).data_element = 'PREF_ALTERNATE_ID'  THEN
      IF x_pref_alternate_id IS NULL THEN
        IF g_partial_if_null  = 'Y' THEN
          l_partial_if_null := TRUE;
          EXIT;
        ELSIF g_matchset_exact(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' AND pref_alternate_id IS NULL');
        END IF;
      ELSE
        fnd_dsql.add_text(' AND UPPER(pref_alternate_id) = ');
        fnd_dsql.add_bind(l_pref_alternate_id);
      END IF;
      -- append the where clause with person id type
    ELSIF g_matchset_exact(i).data_element = 'PERSON_ID_TYPE'  THEN
      IF x_api_person_id IS NULL THEN
        IF g_partial_if_null  = 'Y' THEN
          l_partial_if_null := TRUE;
          EXIT;
        END IF;
      ELSE
        fnd_dsql.add_text(' AND person_id_type = ');
        fnd_dsql.add_bind(l_person_id_type);
        fnd_dsql.add_text(' AND UPPER(api_person_id) = ');
        fnd_dsql.add_bind(l_api_person_id);
	fnd_dsql.add_text(' AND (API_START_DATE <> API_END_DATE OR API_END_DATE IS  NULL) ');
      END IF;
      -- append the where clause with birth date
    ELSIF g_matchset_exact(i).data_element = 'BIRTH_DT'  THEN
      IF x_birth_dt IS NULL THEN
        IF g_partial_if_null = 'Y' THEN
          l_partial_if_null := TRUE;
          EXIT;
        ELSIF g_matchset_exact(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' AND birth_dt IS NULL');
        END IF;
      ELSE
        /* changes made to include trunc function for comparing birth date, for bug number 2158920 */
        fnd_dsql.add_text(' AND TRUNC(birth_dt) = to_date( to_char(');
        fnd_dsql.add_bind(x_birth_dt);
        fnd_dsql.add_text(',''DD-MON-RRRR'') ,''DD-MON-RRRR'')');
      END IF;
      -- append the where clause with sex
    ELSIF g_matchset_exact(i).data_element = 'SEX'  THEN
      IF x_sex IS NULL THEN
        IF NVL(g_partial_if_null, 'N')  = 'Y' THEN
          l_partial_if_null := TRUE;
          EXIT;
        ELSIF NVL(g_matchset_exact(i).drop_if_null, 'N') = 'N' THEN
          fnd_dsql.add_text(' AND sex IS NULL');
        END IF;
      ELSE
        fnd_dsql.add_text(' AND UPPER(sex) = ');
        fnd_dsql.add_bind(l_sex);
      END IF;
      -- append the where clause with ethnic origin
    ELSIF g_matchset_exact(i).data_element = 'ETHNIC_ORIGIN'  THEN
      IF x_ethnic_origin IS NULL THEN
        IF g_partial_if_null = 'Y' THEN
          l_partial_if_null := TRUE;
          EXIT;
        ELSIF g_matchset_exact(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' AND ethnic_origin IS NULL');
        END IF;
      ELSE
        fnd_dsql.add_text(' AND UPPER(ethnic_origin) = ');
        fnd_dsql.add_bind(l_ethnic_origin);
      END IF;
      -- append the where clause with address type
    ELSIF g_matchset_exact(i).data_element = 'ADDR_TYPE'  THEN
      IF x_addr_type IS NULL THEN
        IF g_partial_if_null = 'Y' THEN
          l_partial_if_null := TRUE;
          EXIT;
        ELSIF g_matchset_exact(i).drop_if_null = 'N' THEN  -- basically record will never come here, it will get a E001
          fnd_dsql.add_text(' AND addr_type IS NULL');
        END IF;
      ELSE
        fnd_dsql.add_text(' AND UPPER(addr_type) = ');
        fnd_dsql.add_bind(l_addr_type);
      END IF;
      -- append the where clause with contact address lines
    ELSIF g_matchset_exact(i).data_element = 'CONC_ADDR_LINES' THEN
      IF l_conct_address_lines IS NULL THEN
        IF g_partial_if_null = 'Y' THEN
          l_partial_if_null := TRUE;
          EXIT;
        ELSIF g_matchset_exact(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' AND conct_address_lines IS NULL');
        END IF;
      ELSE
        fnd_dsql.add_text(' AND UPPER(conct_address_lines) = ');
        fnd_dsql.add_bind(l_conct_address_lines);
      END IF;
      -- append the where clause with line 1
    ELSIF g_matchset_exact(i).data_element = 'ADDR_LINE_1'  THEN
      IF x_addr_line_1 IS NULL THEN
        IF g_partial_if_null = 'Y' THEN
          l_partial_if_null := TRUE;
          EXIT;
        ELSIF g_matchset_exact(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' AND addr_line_1 IS NULL');
        END IF;
      ELSE
        fnd_dsql.add_text(' AND UPPER(addr_line_1) = ');
        fnd_dsql.add_bind(l_addr_line_1);
      END IF;
      -- append the where clause with line 2
    ELSIF g_matchset_exact(i).data_element = 'ADDR_LINE_2'  THEN
      IF x_addr_line_2 IS NULL THEN
        IF g_partial_if_null = 'Y' THEN
          l_partial_if_null := TRUE;
          EXIT;
        ELSIF g_matchset_exact(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' AND addr_line_2 IS NULL');
        END IF;
      ELSE
        fnd_dsql.add_text(' AND UPPER(addr_line_2) = ');
        fnd_dsql.add_bind(l_addr_line_2);
      END IF;
      -- append the where clause with line 3
    ELSIF g_matchset_exact(i).data_element = 'ADDR_LINE_3'  THEN
      IF x_addr_line_3 IS NULL THEN
        IF g_partial_if_null = 'Y' THEN
          l_partial_if_null := TRUE;
          EXIT;
        ELSIF g_matchset_exact(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' AND addr_line_3 IS NULL');
        END IF;
      ELSE
        fnd_dsql.add_text(' AND UPPER(addr_line_3) = ');
        fnd_dsql.add_bind(l_addr_line_3);
      END IF;
      -- append the where clause with line 4
    ELSIF g_matchset_exact(i).data_element = 'ADDR_LINE_4'  THEN
      IF x_addr_line_4 IS NULL THEN
        IF g_partial_if_null = 'Y' THEN
          l_partial_if_null := TRUE;
          EXIT;
        ELSIF g_matchset_exact(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' AND addr_line_4 IS NULL');
        END IF;
      ELSE
        fnd_dsql.add_text(' AND UPPER(addr_line_4) = ');
        fnd_dsql.add_bind(l_addr_line_4);
      END IF;
    -- append the where clause with city
    ELSIF g_matchset_exact(i).data_element = 'CITY'  THEN
      IF x_city IS NULL THEN
        IF g_partial_if_null = 'Y' THEN
          l_partial_if_null := TRUE;
          EXIT;
        ELSIF g_matchset_exact(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' AND city IS NULL');
        END IF;
      ELSE
        fnd_dsql.add_text(' AND UPPER(city) = ');
        fnd_dsql.add_bind(l_city);
      END IF;
      -- append the where clause with state
    ELSIF g_matchset_exact(i).data_element = 'STATE'  THEN
      IF x_state IS NULL THEN
        IF g_partial_if_null = 'Y' THEN
          l_partial_if_null := TRUE;
          EXIT;
        ELSIF g_matchset_exact(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' AND state IS NULL');
        END IF;
      ELSE
        fnd_dsql.add_text(' AND UPPER(state) = ');
        fnd_dsql.add_bind(l_state);
      END IF;
      -- append the where clause with province
    ELSIF g_matchset_exact(i).data_element = 'PROVINCE'  THEN
      IF x_province IS NULL THEN
        IF g_partial_if_null = 'Y' THEN
          l_partial_if_null := TRUE;
          EXIT;
        ELSIF g_matchset_exact(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' AND province IS NULL');
        END IF;
      ELSE
        fnd_dsql.add_text(' AND UPPER(province) = ');
        fnd_dsql.add_bind(l_province);
      END IF;
      -- append the where clause with county
    ELSIF g_matchset_exact(i).data_element = 'COUNTY'  THEN
      IF x_county IS NULL THEN
        IF g_partial_if_null = 'Y' THEN
          l_partial_if_null := TRUE;
          EXIT;
        ELSIF g_matchset_exact(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' AND county IS NULL');
        END IF;
      ELSE
        fnd_dsql.add_text(' AND UPPER(county) = ');
        fnd_dsql.add_bind(l_county);
      END IF;
     -- append the where clause with country
    ELSIF g_matchset_exact(i).data_element = 'COUNTRY'  THEN
      IF x_country IS NULL THEN
        IF g_partial_if_null = 'Y' THEN
          l_partial_if_null := TRUE;
          EXIT;
        ELSIF g_matchset_exact(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' AND country IS NULL');
        END IF;
      ELSE
        fnd_dsql.add_text(' AND UPPER(country) = ');
        fnd_dsql.add_bind(l_country);
      END IF;
      -- append the where clause with postcode
    ELSIF g_matchset_exact(i).data_element = 'POSTCODE'  THEN
      IF x_postcode IS NULL THEN
        IF g_partial_if_null = 'Y' THEN
          l_partial_if_null := TRUE;
          EXIT;
        ELSIF g_matchset_exact(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' AND postcode IS NULL');
        END IF;
      ELSE
        fnd_dsql.add_text(' AND UPPER(postcode) = ');
        fnd_dsql.add_bind(l_postcode);
      END IF;
    END IF;
  END LOOP;
  -- ssawhney : changes in the logic for Devry MCS issue bug 3005910

  -- Form the select statement with the where clause formed.
  IF l_partial_if_null THEN
    l_SelectClause := 'PARTIAL_MATCH';
  ELSE
    l_SelectClause := fnd_dsql.get_text(FALSE);
  END IF;

 END IF;


  -- If the match category is partial then form the where clause by appending the data elements with 'OR'
 IF x_match_category = 'P' THEN

  -- this logic was added, to diferentiate parital and exact if ONLY one element is select in the MCS for partial
  fnd_dsql.add_text(' AND ( 1=2 ');

  FOR i IN 1..g_matchset_partial.COUNT LOOP
    l_partial_clause := TRUE;

      -- append the where clause with given name
    IF g_matchset_partial(i).data_element = 'GIVEN_NAME'  THEN
      IF X_GIVEN_NAMES IS NULL THEN
        IF g_matchset_partial(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' OR  given_names IS NULL');
        END IF;
      ELSE
        fnd_dsql.add_text(' OR UPPER(given_names) = ');
        fnd_dsql.add_bind(l_given_names);
      END IF;
      --Bug 3146324 obsoleted alternate Id
      -- append the where clause with preferred alternate id
    ELSIF g_matchset_partial(i).data_element = 'PREF_ALTERNATE_ID'  THEN
      IF x_pref_alternate_id IS NULL THEN
        IF g_matchset_partial(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' OR pref_alternate_id IS NULL');
        END IF;
      ELSE
        fnd_dsql.add_text(' OR UPPER(pref_alternate_id) = ');
        fnd_dsql.add_bind(l_pref_alternate_id);
      END IF;
     -- append the where clause with person id type
     -- devry matchset issue. person id type should not be treated in standalone mode.
     -- code is uncommented as alternate id is made as obsolete
    ELSIF g_matchset_partial(i).data_element = 'PERSON_ID_TYPE'  THEN
      IF x_api_person_id IS NOT NULL THEN
        fnd_dsql.add_text(' OR ( UPPER(api_person_id) = ');
        fnd_dsql.add_bind(l_api_person_id);
	fnd_dsql.add_text(' AND person_id_type=');
	fnd_dsql.add_bind(l_person_id_type);
	fnd_dsql.add_text(')');
      END IF;
      -- append the where clause with birth date
    ELSIF g_matchset_partial(i).data_element = 'BIRTH_DT'  THEN
      IF x_birth_dt IS NULL THEN
        IF g_matchset_partial(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' OR birth_dt IS NULL');
        END IF;
      ELSE
        /* changes made to include trunc function for comparing birth date, for bug number 2158920 */
        fnd_dsql.add_text(' OR TRUNC(birth_dt) = to_date( to_char(');
        fnd_dsql.add_bind(x_birth_dt);
        fnd_dsql.add_text(',''DD-MON-RRRR'') ,''DD-MON-RRRR'')');
      END IF;
      -- append the where clause with sex
    ELSIF g_matchset_partial(i).data_element = 'SEX'  THEN
      IF x_sex IS NULL THEN
        IF g_matchset_partial(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' OR sex IS NULL');
        END IF;
      ELSE
        fnd_dsql.add_text(' OR UPPER(sex) = ');
        fnd_dsql.add_bind(l_sex);
      END IF;
      -- append the where clause with ethnic origin
    ELSIF g_matchset_partial(i).data_element = 'ETHNIC_ORIGIN'  THEN
      IF x_ethnic_origin IS NULL THEN
        IF g_matchset_partial(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' OR ethnic_origin IS NULL');
        END IF;
      ELSE
        fnd_dsql.add_text(' OR UPPER(ethnic_origin) = ');
        fnd_dsql.add_bind(l_ethnic_origin);
      END IF;
      -- append the where clause with address type
      -- Devry MCS 3005910 address type not to be treated separately.
      -- append the where clause with contact address lines
    ELSIF g_matchset_partial(i).data_element = 'CONC_ADDR_LINES' THEN
      IF l_conct_address_lines IS NULL THEN
        IF g_matchset_partial(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' OR (conct_address_lines IS NULL');
	  IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
	    fnd_dsql.add_text(' AND addr_type = ');
	    fnd_dsql.add_bind(l_addr_type);
	  END IF;
	  fnd_dsql.add_text(')');
        END IF;
      ELSE
        fnd_dsql.add_text(' OR ( UPPER(conct_address_lines) = ');
        fnd_dsql.add_bind(l_conct_address_lines);
   	  IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
	    fnd_dsql.add_text(' AND addr_type = ');
	    fnd_dsql.add_bind(l_addr_type);
	  END IF;
	  fnd_dsql.add_text(')');
      END IF;
      -- append the where clause with line 1
    ELSIF g_matchset_partial(i).data_element = 'ADDR_LINE_1'  THEN
      IF x_addr_line_1 IS NULL THEN
        IF g_matchset_partial(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' OR ( addr_line_1 IS NULL ');
	  IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
	    fnd_dsql.add_text(' AND addr_type = ');
	    fnd_dsql.add_bind(l_addr_type);
	  END IF;
	  fnd_dsql.add_text(')');
        END IF;
      ELSE
        fnd_dsql.add_text(' OR ( UPPER(addr_line_1) = ');
        fnd_dsql.add_bind(l_addr_line_1);
        IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
	  fnd_dsql.add_text(' AND addr_type = ');
	  fnd_dsql.add_bind(l_addr_type);
        END IF;
	  fnd_dsql.add_text(')');
      END IF;
      -- append the where clause with line 2
    ELSIF g_matchset_partial(i).data_element = 'ADDR_LINE_2'  THEN
      IF x_addr_line_2 IS NULL THEN
        IF g_matchset_partial(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' OR ( addr_line_2 IS NULL');
	  IF Igs_Pe_Identify_Dups.g_primary_addr_flag  = 'N' THEN
	    fnd_dsql.add_text (' AND addr_type = ');
	    fnd_dsql.add_bind(l_addr_type);
	  END IF;
          fnd_dsql.add_text (' ) ');
        END IF;
      ELSE
        fnd_dsql.add_text(' OR ( UPPER(addr_line_2) = ');
        fnd_dsql.add_bind(l_addr_line_2);
   	IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
	  fnd_dsql.add_text(' AND addr_type = ');
	  fnd_dsql.add_bind(l_addr_type);
	END IF;
	fnd_dsql.add_text(')');
      END IF;
      -- append the where clause with line 3
    ELSIF g_matchset_partial(i).data_element = 'ADDR_LINE_3'  THEN
      IF x_addr_line_3 IS NULL THEN
        IF g_matchset_partial(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' OR ( addr_line_3 IS NULL');
	  IF Igs_Pe_Identify_Dups.g_primary_addr_flag  = 'N' THEN
	    fnd_dsql.add_text (' AND addr_type = ');
	    fnd_dsql.add_bind(l_addr_type);
	  END IF;
          fnd_dsql.add_text (' ) ');
        END IF;
      ELSE
        fnd_dsql.add_text(' OR ( UPPER(addr_line_3) = ');
        fnd_dsql.add_bind(l_addr_line_3);
        IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
 	  fnd_dsql.add_text(' AND addr_type = ');
	  fnd_dsql.add_bind(l_addr_type);
	END IF;
	fnd_dsql.add_text(')');
      END IF;
     -- append the where clause with line 4
    ELSIF g_matchset_partial(i).data_element = 'ADDR_LINE_4'  THEN
      IF x_addr_line_4 IS NULL THEN
        IF g_matchset_partial(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' OR ( addr_line_4 IS NULL');
	  IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
	    fnd_dsql.add_text(' AND addr_type = ');
	    fnd_dsql.add_bind(l_addr_type);
	  END IF;
	  fnd_dsql.add_text(')');
        END IF;
      ELSE
        fnd_dsql.add_text(' OR  ( UPPER(addr_line_4) = ');
        fnd_dsql.add_bind(l_addr_line_4);
   	IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
	  fnd_dsql.add_text(' AND addr_type = ');
	  fnd_dsql.add_bind(l_addr_type);
	END IF;
	fnd_dsql.add_text(')');
      END IF;
      -- append the where clause with city
    ELSIF g_matchset_partial(i).data_element = 'CITY'  THEN
      IF x_city IS NULL THEN
        IF g_matchset_partial(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' OR ( city IS NULL');
	  IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
	    fnd_dsql.add_text(' AND addr_type = ');
	    fnd_dsql.add_bind(l_addr_type);
	  END IF;
	  fnd_dsql.add_text(')');
        END IF;
      ELSE
        fnd_dsql.add_text(' OR ( UPPER(city) = ');
        fnd_dsql.add_bind(l_city);
        IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
          fnd_dsql.add_text(' AND addr_type = ');
	  fnd_dsql.add_bind(l_addr_type);
        END IF;
        fnd_dsql.add_text(')');
      END IF;
      -- append the where clause with state
    ELSIF g_matchset_partial(i).data_element = 'STATE'  THEN
      IF x_state IS NULL THEN
        IF g_matchset_partial(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' OR ( state IS NULL');
	  IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
	    fnd_dsql.add_text(' AND addr_type = ');
	    fnd_dsql.add_bind(l_addr_type);
	  END IF;
	  fnd_dsql.add_text(')');
        END IF;
      ELSE
        fnd_dsql.add_text(' OR ( UPPER(state) = ');
        fnd_dsql.add_bind(l_state);
   	IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
	  fnd_dsql.add_text(' AND addr_type = ');
	  fnd_dsql.add_bind(l_addr_type);
	END IF;
	fnd_dsql.add_text(')');
      END IF;
    -- append the where clause with province
    ELSIF g_matchset_partial(i).data_element = 'PROVINCE'  THEN
      IF x_province IS NULL THEN
        IF g_matchset_partial(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' OR ( province IS NULL');
	  IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
	    fnd_dsql.add_text(' AND addr_type = ');
	    fnd_dsql.add_bind(l_addr_type);
	  END IF;
	  fnd_dsql.add_text(')');
        END IF;
      ELSE
        fnd_dsql.add_text(' OR ( UPPER(province) = ');
        fnd_dsql.add_bind(l_province);
   	IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
	  fnd_dsql.add_text(' AND addr_type = ');
	  fnd_dsql.add_bind(l_addr_type);
	END IF;
	fnd_dsql.add_text(')');
      END IF;
    -- append the where clause with county
    ELSIF g_matchset_partial(i).data_element = 'COUNTY'  THEN
      IF x_county IS NULL THEN
        IF g_matchset_partial(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' OR ( county IS NULL');
	  IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
	    fnd_dsql.add_text(' AND addr_type = ');
	    fnd_dsql.add_bind(l_addr_type);
	  END IF;
	  fnd_dsql.add_text(')');
        END IF;
      ELSE
        fnd_dsql.add_text(' OR ( UPPER(county) = ');
        fnd_dsql.add_bind(l_county);
        IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
	  fnd_dsql.add_text(' AND addr_type = ');
	  fnd_dsql.add_bind(l_addr_type);
	END IF;
	fnd_dsql.add_text(')');
      END IF;
      -- append the where clause with country
    ELSIF g_matchset_partial(i).data_element = 'COUNTRY'  THEN
      IF x_country IS NULL THEN
        IF g_matchset_partial(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' OR (country IS NULL');
    	  IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
	    fnd_dsql.add_text(' AND addr_type = ');
	    fnd_dsql.add_bind(l_addr_type);
	  END IF;
	  fnd_dsql.add_text(')');
        END IF;
      ELSE
        fnd_dsql.add_text(' OR ( UPPER(country) = ');
        fnd_dsql.add_bind(l_country);
   	IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
	  fnd_dsql.add_text(' AND addr_type = ');
	  fnd_dsql.add_bind(l_addr_type);
	END IF;
	fnd_dsql.add_text(')');
      END IF;
      -- append the where clause with postcode
    ELSIF g_matchset_partial(i).data_element = 'POSTCODE'  THEN
      IF x_postcode IS NULL THEN
        IF g_matchset_partial(i).drop_if_null = 'N' THEN
          fnd_dsql.add_text(' OR ( postcode IS NULL');
 	  IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
	    fnd_dsql.add_text(' AND addr_type = ');
	    fnd_dsql.add_bind(l_addr_type);
	  END IF;
	  fnd_dsql.add_text(')');
        END IF;
      ELSE
        fnd_dsql.add_text(' OR ( UPPER(postcode) = ');
        fnd_dsql.add_bind(l_postcode);
	IF Igs_Pe_Identify_Dups.g_primary_addr_flag = 'N' THEN
	  fnd_dsql.add_text(' AND addr_type = ');
	  fnd_dsql.add_bind(l_addr_type);
	END IF;
	fnd_dsql.add_text(')');
      END IF;
    END IF;
  END LOOP;

  -- Form the where clause by appending the select clause with where clause
  IF l_partial_clause THEN
    fnd_dsql.add_text(')');
    l_SelectClause := fnd_dsql.get_text(FALSE);
  ELSE
    l_SelectClause := l_default_sql_text;
  END IF;
 END IF;
  -- Return the select statement to the called procedure.
  -- ssawhney display output.
 -- Fnd_File.PUT_LINE(Fnd_File.log, l_selectclause);
  x_select_clause := l_SelectClause;
  EXCEPTION
    WHEN OTHERS THEN
      x_retcode := '2';
     FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
     FND_MESSAGE.SET_TOKEN('NAME','igs_pe_identify_dups.form_dup_whereclause'||'-'||SQLERRM);
     APP_EXCEPTION.RAISE_EXCEPTION;
  END;

 PROCEDURE Find_dup_rel_per(
   P_REL_DUP_REC IN r_record_dup_rel,
   P_MATCH_FOUND OUT NOCOPY VARCHAR2
   ) IS

   /*
   Created By: Npalanis , 28-MAY-2003
   Purpose : Import Process Relationship duplicate match
   Change History
   Who        when          What
   */

   l_rowid VARCHAR2(30);
   l_near_mtch_ind igs_ad_imp_near_mtch_all.near_mtch_id%TYPE;
   l_count NUMBER(7) := 0;
   l_stmt VARCHAR2(2000);
   l_person_id igs_pe_person_base_v.person_id%TYPE;

   TYPE dup_check_cur IS REF CURSOR;
   dup_check_rec dup_check_cur;
   l_cursor_id NUMBER(15);
   l_num_of_rows NUMBER(10);

   BEGIN

      /* Delete from igs_ad_near_match_int all old occurances */
        DECLARE
        CURSOR tbh_cur IS
        SELECT ROWID
        FROM  igs_ad_imp_near_mtch_all
        WHERE interface_relations_id = P_REL_DUP_REC.INTERFACE_RELATIONS_ID;
        tbh_rec tbh_cur%ROWTYPE;
      BEGIN
        OPEN tbh_cur;
        LOOP
        FETCH tbh_cur INTO tbh_rec;
        EXIT WHEN tbh_cur%NOTFOUND;
        Igs_Ad_Imp_Near_Mtch_Pkg.delete_row(tbh_rec.ROWID);
        END LOOP;
        CLOSE tbh_cur;
      END;

      fnd_dsql.init;

      fnd_dsql.add_text('SELECT person_id FROM igs_pe_person_base_v WHERE UPPER(first_name) =UPPER(');
      fnd_dsql.add_bind(P_REL_DUP_REC.FIRST_NAME);
      fnd_dsql.add_text(') AND UPPER (last_name) = UPPER (');
      fnd_dsql.add_bind(P_REL_DUP_REC.SURNAME);
      fnd_dsql.add_text(') AND ( 1 = 2 OR ');

      IF P_REL_DUP_REC.GENDER IS NULL AND P_REL_DUP_REC.BIRTH_DATE IS NULL THEN
       fnd_dsql.add_text(' gender IS NULL OR birth_date IS NULL)');

      ELSIF P_REL_DUP_REC.GENDER IS NOT NULL AND P_REL_DUP_REC.BIRTH_DATE IS NULL THEN
        fnd_dsql.add_text(' gender = ');
        fnd_dsql.add_bind(P_REL_DUP_REC.gender);
        fnd_dsql.add_text(' OR birth_date IS NULL)');

      ELSIF P_REL_DUP_REC.GENDER IS NULL AND P_REL_DUP_REC.BIRTH_DATE IS NOT NULL THEN
        fnd_dsql.add_text(' gender IS NULL OR birth_date = ');
        fnd_dsql.add_bind(TO_DATE(TO_CHAR(P_REL_DUP_REC.birth_date,'DD-MON-RRRR'),'DD/MM/RRRR'));
        fnd_dsql.add_text(')');

      ELSE
        fnd_dsql.add_text(' gender = ');
        fnd_dsql.add_bind(P_REL_DUP_REC.gender);
        fnd_dsql.add_text(' OR birth_date = ');
        fnd_dsql.add_bind(TO_DATE(TO_CHAR(P_REL_DUP_REC.birth_date,'DD-MON-RRRR'),'DD/MM/RRRR'));
        fnd_dsql.add_text(')');

      END IF;

   l_stmt := fnd_dsql.get_text(FALSE);
   l_cursor_id := dbms_sql.open_cursor;
   fnd_dsql.set_cursor(l_cursor_id);
   dbms_sql.parse(l_cursor_id, l_stmt, dbms_sql.native);
   fnd_dsql.do_binds;

   dbms_sql.define_column(l_cursor_id, 1, l_person_id);

   l_num_of_rows := dbms_sql.EXECUTE(l_cursor_id);

   LOOP

                   IF dbms_sql.fetch_rows(l_cursor_id) > 0 THEN
                        dbms_sql.column_value(l_cursor_id, 1, l_person_id);
                   ELSE
                           EXIT;
                   END IF;
                   l_count := l_count + 1;
                   IGS_AD_IMP_NEAR_MTCH_PKG.INSERT_ROW(
                               X_ROWID                => l_rowid ,
                               X_ORG_ID               => NULL,
                               X_NEAR_MTCH_ID         => l_near_mtch_ind ,
                               X_INTERFACE_ID         => P_REL_DUP_REC.INTERFACE_ID,
                               X_PERSON_ID            => l_person_id,
                               X_MATCH_IND            => 'P',
                               X_ACTION               => null,
                               X_ADDR_TYPE            => null,
                               X_PERSON_ID_TYPE       => Null,
                               X_MATCH_SET_ID         => P_REL_DUP_REC.match_set_id,
                               X_MODE                 => 'I',
                               X_PARTY_SITE_ID        => null,
                               X_INTERFACE_RELATIONS_ID =>P_REL_DUP_REC.INTERFACE_RELATIONS_ID);

   END LOOP;

   IF l_count = 0 THEN
      p_match_found := 'N';
   ELSIF l_count > 0 THEN
      p_match_found := 'Y';
   END IF;


  END Find_dup_rel_per;

END Igs_Pe_Identify_Dups;

/
