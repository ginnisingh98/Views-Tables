--------------------------------------------------------
--  DDL for Package Body HXC_SEEDDATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_SEEDDATA_PKG" AS
/* $Header: hxcseeddatapkg.pkb 120.2 2006/03/23 02:39:59 gsirigin noship $ */

   FUNCTION get_query(p_object_type in varchar2)
   RETURN VARCHAR2
   IS

     l_layouts VARCHAR2(1000)
            := 'select Layout_Name Value, Layout_ID ID from hxc_layouts ';

     l_alias_definitions VARCHAR2(1000)
            := 'select alias_definition_name VALUE,alias_definition_id ID from hxc_alias_definitions
                 ';

     l_alias_types VARCHAR2(1000)
            :=  'select ALIAS_TYPE||''-''||REFERENCE_OBJECT Value,ALIAS_TYPE_ID ID from hxc_alias_types
                 ';


     l_time_sources VARCHAR2(1000)
     	  := 'SELECT NAME VALUE, time_source_id id
	 		  FROM hxc_time_sources
	 	  	  ';

     l_time_recipient VARCHAR2(1000)
          := 'SELECT NAME VALUE, time_recipient_id id
                FROM hxc_time_recipients
                ';

     l_mapping_comps VARCHAR2(1000)
            := 'SELECT NAME VALUE, mapping_component_id ID
	             FROM hxc_mapping_components
	            ';

     l_mappings VARCHAR2(1000)
           := 'SELECT NAME VALUE, mapping_id ID
                 FROM hxc_mappings
                ';


     l_retrieval_processes VARCHAR2(1000)
          := 'SELECT NAME VALUE, retrieval_process_id id
                FROM hxc_retrieval_processes
               ';


     l_retrieval_rules VARCHAR2(1000)
           := 'SELECT NAME VALUE, retrieval_rule_id id
                 FROM hxc_retrieval_rules
                ';


     l_deposit_processes VARCHAR2(1000)
          := 'SELECT NAME VALUE, deposit_process_id id
                FROM hxc_deposit_processes
               ';


      l_approval_styles   VARCHAR2 (1000)
         := 'SELECT has.NAME VALUE, has.approval_style_id id
               FROM hxc_approval_styles has
               ';

      l_data_approval_rule VARCHAR2(1000)
          := '   SELECT dar.NAME Value, dru.data_app_rule_usage_id id
                 FROM hxc_time_entry_rules dar, hxc_data_app_rule_usages dru
                 WHERE dru.time_entry_rule_id = dar.time_entry_rule_id
	               ';

     l_recurring_periods VARCHAR2(1000)
          := 'SELECT NAME VALUE, recurring_period_id id
                FROM hxc_recurring_periods
               ';

     l_approval_period_set VARCHAR2(1000)
          := 'SELECT NAME VALUE, approval_period_set_id id
                FROM hxc_approval_period_sets
                ';


     l_application_set VARCHAR2(1000)
            := '   SELECT heg.NAME Value, heg.entity_group_id ID
                     FROM hxc_entity_groups heg
                    WHERE heg.entity_type = ''TIME_RECIPIENTS''
	                   ';

     l_time_entry_rule_groups VARCHAR2(1000)
            := '   SELECT heg.NAME Value, heg.entity_group_id ID
                     FROM hxc_entity_groups heg
                    WHERE heg.entity_type = ''TIME_ENTRY_RULES''
	                   ';


     l_retrieval_rule_groups VARCHAR2(1000)
            := '   SELECT heg.NAME Value, heg.entity_group_id ID
                     FROM hxc_entity_groups heg
                    WHERE heg.entity_type = ''RETRIEVAL_RULES''
	                   ';


     l_time_category VARCHAR2(1000)
         := 'SELECT time_category_name VALUE, time_category_id id
               FROM hxc_time_categories
              ';


     l_locker_types VARCHAR2(1000)
            :=   'SELECT LOCKER_TYPE||''-''||PROCESS_TYPE VALUE, locker_type_id ID
                    FROM hxc_locker_types
                   ';


     l_pref_hierarchies VARCHAR2(1000)
            := 'SELECT name Value,pref_hierarchy_id ID FROM hxc_pref_hierarchies
                ';


     l_time_entry_rules VARCHAR2(1000)
           := 'SELECT NAME VALUE, time_entry_rule_id id
  				 FROM hxc_time_entry_rules
                ';


   l_query varchar2(1000);

   BEGIN

	  IF (p_object_type = 'HXC_LAYOUTS') THEN
         l_query := l_layouts;
      ELSIF (p_object_type = 'HXC_ALIAS_DEFINITIONS') THEN
	     l_query := l_alias_definitions;
      ELSIF (p_object_type = 'HXC_ALIAS_TYPES') THEN
	     l_query := l_alias_types;
      ELSIF (p_object_type = 'HXC_TIME_SOURCES') THEN
         l_query := l_time_sources;
      ELSIF (p_object_type = 'HXC_TIME_RECIPIENTS') THEN
         l_query := l_time_recipient;
      ELSIF (p_object_type = 'HXC_MAPPING_COMPONENTS') THEN
	     l_query := l_mapping_comps;
      ELSIF (p_object_type = 'HXC_MAPPINGS') THEN
	     l_query := l_mappings;
      ELSIF (p_object_type = 'HXC_RETRIEVAL_PROCESSES') THEN
	     l_query := l_retrieval_processes;
      ELSIF (p_object_type = 'HXC_RETRIEVAL_RULES') THEN
	     l_query := l_retrieval_rules;
      ELSIF (p_object_type = 'HXC_DEPOSIT_PROCESSES') THEN
	     l_query := l_deposit_processes;
      ELSIF (p_object_type = 'HXC_APPROVAL_STYLES') THEN
         l_query := l_approval_styles;
      ELSIF (p_object_type = 'HXC_DATA_APPROVAL_RULES') THEN
         l_query := l_data_approval_rule;
      ELSIF (p_object_type = 'HXC_RECURRING_PERIODS') THEN
	     l_query := l_recurring_periods;
      ELSIF (p_object_type = 'HXC_APPROVAL_PERIOD_SETS') THEN
	     l_query := l_approval_period_set;
      ELSIF (p_object_type = 'HXC_APPLICATION_SETS') THEN
	     l_query := l_application_set;
	  ELSIF (p_object_type = 'HXC_TIME_ENTRY_RULE_GROUPS') THEN
         l_query := l_time_entry_rule_groups;
      ELSIF (p_object_type = 'HXC_RETRIEVAL_RULE_GROUPS') THEN
         l_query := l_retrieval_rule_groups;
      ELSIF (p_object_type = 'HXC_TIME_CATEGORIES') THEN
         l_query := l_time_category;
	  ELSIF (p_object_type = 'HXC_LOCKER_TYPES') THEN
         l_query := l_locker_types;
	  ELSIF (p_object_type = 'HXC_PREF_HIERARCHIES') THEN
         l_query := l_pref_hierarchies;
      ELSIF (p_object_type = 'HXC_TIME_ENTRY_RULES') THEN
	     l_query := l_time_entry_rules;
      END IF;

      return l_query;

   END get_query;


   FUNCTION get_value ( p_object_id in number,
                        p_object_type in varchar2 )
   RETURN VARCHAR2
   IS

   TYPE get_value IS REF CURSOR; -- define REF CURSOR type
   c_get_value   get_value; -- declare cursor variable

   l_value VARCHAR2(150);
   l_query varchar2(1000);

   BEGIN

   --we need to get the values
   --for that we need the query
   l_query := get_query(p_object_type);

   if l_query is not null then
	   --we need to modify the query a little bit
	   l_query := 'SELECT Value from ('||l_query||') where ID = :p_object_id';

	   OPEN c_get_value FOR l_query USING p_object_id;
	   FETCH c_get_value INTO l_value;
	   CLOSE c_get_value;

	   RETURN l_value;
   else
       RETURN null;
   end if;
   END get_value;

   FUNCTION get_legislation_code(p_object_id in number,
                                 p_object_type in varchar2 )
   RETURN varchar2 IS


   cursor c_alias_definitions is
   select legislation_code from hxc_alias_definitions
    where alias_definition_id = p_object_id;

   cursor c_pref_hierarchies is
   select legislation_code from hxc_pref_hierarchies
    where pref_hierarchy_id = p_object_id;

   cursor c_approval_styles is
   select legislation_code from hxc_approval_styles
    where approval_style_id = p_object_id;

   cursor c_time_entry_rules is
   select legislation_code from hxc_time_entry_rules
    where time_entry_rule_id = p_object_id;

   l_legislation_code varchar2(30);

   BEGIN

      IF (p_object_type = 'HXC_APPROVAL_STYLES') THEN
         open c_alias_definitions;
         fetch c_alias_definitions into l_legislation_code;
         close c_alias_definitions;
      ELSIF (p_object_type = 'HXC_TIME_ENTRY_RULES') THEN
         open c_pref_hierarchies;
         fetch c_pref_hierarchies into l_legislation_code;
         close c_pref_hierarchies;
	  ELSIF (p_object_type = 'HXC_PREF_HIERARCHIES') THEN
         open c_approval_styles;
         fetch c_approval_styles into l_legislation_code;
         close c_approval_styles;
      ELSIF (p_object_type = 'HXC_ALIAS_DEFINITIONS') THEN
         open c_time_entry_rules;
         fetch c_time_entry_rules into l_legislation_code;
         close c_time_entry_rules;
      ELSE
         l_legislation_code := null;
      END IF;

     return l_legislation_code;

   END get_legislation_code;



   PROCEDURE hxc_seeddata_by_level_query
       (p_seeddata_by_level_data in out NOCOPY t_rec,
        p_object_type in varchar2,
        p_value in varchar2,
        p_application_name in varchar2,
        p_code_level_required in varchar2,
        p_count out NOCOPY number
        )
   IS

         TYPE ref_cur IS REF CURSOR; -- define REF CURSOR type

         c_get_value         ref_cur; -- declare cursor variable

         l_query             VARCHAR2 (2000);
         l_index             BINARY_INTEGER;


         c_get_seed_data ref_cur;

         l_get_seed_data VARCHAR2(1000) :=
            'SELECT hsbl.owner_application_id, hsbl.hxc_required, hrl.meaning code_level_required,
                   faptl.application_name, hsbl.created_by, hsbl.creation_date,
                   hsbl.last_updated_by, hsbl.last_update_date, hsbl.last_update_login
              FROM hxc_seeddata_by_level hsbl,
                   hr_lookups hrl,
                   fnd_application fap,
                   fnd_application_tl faptl
             WHERE hsbl.object_id = :p_object_id
               AND hsbl.object_type = :p_object_type
               AND hrl.lookup_type = ''HXC_REQUIRED''
               AND hrl.lookup_code = hsbl.hxc_required
               AND fap.application_id = hsbl.owner_application_id
               AND faptl.APPLICATION_ID = fap.application_id
			   AND faptl.LANGUAGE = USERENV (''LANG'')';


           TYPE r_seed_rec is RECORD (
		      owner_application_id   NUMBER (15),
		      HXC_REQUIRED           VARCHAR2(30),
		      code_level_required    VARCHAR2 (80),
		      application_name       VARCHAR2 (240),
		      created_by             NUMBER(15),
		      creation_date          DATE,
		      last_updated_by        number(15),
		      last_update_date       date,
		      last_update_login      number(15)
		      );

              l_seed_rec    r_seed_rec;


   BEGIN

      p_count := 0;

      l_query := get_query(p_object_type);


      IF l_query is not null then


		  if p_value is not null then
		  	l_query := 'select value,id from ('||l_query||') where value like :p_value';
		  end if;

		  if p_application_name is not null then
		    l_get_seed_data := l_get_seed_data || ' AND faptl.application_name like :p_application_name';
		  end if;
		  if p_code_level_required is not null then
		    l_get_seed_data := l_get_seed_data ||' AND faptl.application_name like :p_code_level_required';
		  end if;
		  l_index := 1;

		  if p_value is not null then
		      OPEN c_get_value FOR l_query using p_value;
		  else
		      OPEN c_get_value FOR l_query;
		  end if;

		  LOOP

			 FETCH c_get_value INTO p_seeddata_by_level_data (l_index).VALUE,p_seeddata_by_level_data (l_index).object_id;
			 EXIT WHEN c_get_value%NOTFOUND;

			 p_seeddata_by_level_data (l_index).object_type := p_object_type;

			 if p_application_name is not null AND p_code_level_required is not null then
			 OPEN c_get_seed_data FOR l_get_seed_data USING  p_seeddata_by_level_data (l_index).object_id,
			      p_seeddata_by_level_data (l_index).object_type, p_application_name, p_code_level_required;

			 elsif p_application_name is not null AND p_code_level_required is null then
			 OPEN c_get_seed_data FOR l_get_seed_data USING  p_seeddata_by_level_data (l_index).object_id,
			      p_seeddata_by_level_data (l_index).object_type, p_application_name;

			 elsif p_application_name is null AND p_code_level_required is not null then
			 OPEN c_get_seed_data FOR l_get_seed_data USING  p_seeddata_by_level_data (l_index).object_id,
			      p_seeddata_by_level_data (l_index).object_type, p_code_level_required;
			 else
			 OPEN c_get_seed_data FOR l_get_seed_data USING  p_seeddata_by_level_data (l_index).object_id,
			      p_seeddata_by_level_data (l_index).object_type;
			 end if;

			 FETCH c_get_seed_data INTO l_seed_rec;

			 IF c_get_seed_data%FOUND
			 THEN

				p_seeddata_by_level_data (l_index).owner_application_id := l_seed_rec.owner_application_id;
				p_seeddata_by_level_data (l_index).code_level_required := l_seed_rec.code_level_required;
				p_seeddata_by_level_data (l_index).application_name := l_seed_rec.application_name;
				p_seeddata_by_level_data (l_index).created_by := l_seed_rec.created_by;
				p_seeddata_by_level_data (l_index).creation_date := l_seed_rec.creation_date;
				p_seeddata_by_level_data (l_index).last_updated_by := l_seed_rec.last_updated_by;
				p_seeddata_by_level_data (l_index).last_update_date := l_seed_rec.last_update_date;
				p_seeddata_by_level_data (l_index).last_update_login := l_seed_rec.last_update_login;
				p_seeddata_by_level_data (l_index).hxc_required := l_seed_rec.hxc_required;

				p_count := p_count + 1;

			 ELSE

			     -- check if p_application_name or p_code_level_required is not null
			     -- if so we will delete this record
                if p_application_name is not null or p_code_level_required is not null then
	         	    p_seeddata_by_level_data.delete(l_index);
         	    else
         	        p_count := p_count + 1;
         	    end if;

			 END IF;

			 CLOSE c_get_seed_data;

			 l_index := l_index + 1;
		  END LOOP;
		  CLOSE c_get_value;
      END IF;

   END hxc_seeddata_by_level_query;


END HXC_SEEDDATA_PKG;

/
