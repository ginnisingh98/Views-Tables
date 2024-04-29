--------------------------------------------------------
--  DDL for Package Body HXC_TIME_CATEGORY_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIME_CATEGORY_UTILS_PKG" as
/* $Header: hxchtcutl.pkb 120.17.12010000.6 2009/07/21 13:29:36 asrajago ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--

g_debug boolean := hr_utility.debug_enabled;

-- caching structures

TYPE rec_time_category_cache IS RECORD ( operator    hxc_time_categories.operator%TYPE
                                       , start_index PLS_INTEGER
                                       , stop_index  PLS_INTEGER
                                       , time_sql    LONG
                                       , cache_date  DATE );

TYPE tab_time_category_cache IS TABLE OF rec_time_category_cache INDEX BY BINARY_INTEGER;

g_tc_cache tab_time_category_cache;

TYPE rec_time_category_component IS RECORD ( type                 hxc_time_category_comps.type%TYPE
                                           , ref_tc_id            hxc_time_category_comps.time_category_id%TYPE
                                           , sql_string           CLOB );

TYPE tab_time_category_component IS TABLE OF rec_time_category_component INDEX BY BINARY_INTEGER;

g_tc_component_cache tab_time_category_component;

TYPE rec_time_category_bb_ok_cache IS RECORD ( timecard_id     hxc_time_building_blocks.time_building_block_id%TYPE
                                              ,attribute_count NUMBER
                                              ,bb_ok_string    VARCHAR2(32000) );

TYPE tab_time_category_bb_ok_cache IS TABLE OF rec_time_category_bb_ok_cache INDEX BY BINARY_INTEGER;

g_tc_bb_ok_cache tab_time_category_bb_ok_cache;

-- bld blk types

TYPE tab_bb_id        IS TABLE OF hxc_time_building_blocks.time_building_block_id%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_measure      IS TABLE OF hxc_time_building_blocks.measure%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_type         IS TABLE OF hxc_time_building_blocks.type%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_start_time   IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE tab_stop_time    IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE tab_scope        IS TABLE OF hxc_time_building_blocks.scope%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_comment_text IS TABLE OF hxc_time_building_blocks.comment_text%TYPE INDEX BY BINARY_INTEGER;

-- attribute types

TYPE tab_time_attribute_id    IS TABLE OF hxc_time_attributes.time_attribute_id%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_attribute_category   IS TABLE OF hxc_time_attributes.attribute_category%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_attribute            IS TABLE OF hxc_time_attributes.attribute1%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_bld_blk_info_type_id IS TABLE OF hxc_time_attributes.bld_blk_info_type_id%TYPE INDEX BY BINARY_INTEGER;

TYPE eval_time_category_params IS RECORD (
                                   p_time_category_id     hxc_time_categories.time_category_id%TYPE
                               ,   p_use_tc_cache         BOOLEAN
                               ,   p_use_tc_bb_cache      BOOLEAN
                               ,   p_use_temp_table       BOOLEAN
                               ,   p_scope                VARCHAR2(10)
                               ,   p_tbb_id                hxc_time_building_blocks.time_building_block_id%TYPE
                               ,   p_tbb_ovn               hxc_time_building_blocks.object_version_number%TYPE );

g_params eval_time_category_params;

/* Bug 5076837 used to store the time_categories along with the category component status
if the time_category does not have any component then the status will be true
otherwise it will be false */

TYPE rec_empty_time_category is record ( p_status BOOLEAN);

TYPE tab_empty_time_category IS TABLE OF rec_empty_time_category INDEX BY BINARY_INTEGER;

g_empty_time_category_tab tab_empty_time_category;
/* end of changes for bug 5076837 */


l_first_time_round BOOLEAN;

l_continue_evaluation BOOLEAN := TRUE;

l_tc_bb_cache_exists BOOLEAN := FALSE;
l_tc_cache_exists    BOOLEAN := FALSE;

l_operator         hxc_time_categories.operator%TYPE;

CURSOR  csr_get_operator ( p_time_category_id NUMBER ) IS
SELECT  operator
FROM    hxc_time_categories
WHERE   time_category_id = p_time_category_id;


CURSOR	csr_get_category_comps ( p_time_category_id NUMBER ) IS
SELECT
	bbit.bld_blk_info_type context
,	bbit.bld_blk_info_type_id
,	mpc.segment
,	NVL(tcc.value_id, DECODE(tcc.is_null, 'N', '<WILDCARD>', '<IS NULL>')) value_id
,	tcc.ref_time_category_id
,	tcc.flex_value_set_id
,       tcc.equal_to
FROM
        hxc_bld_blk_info_types bbit
,       hxc_mapping_components mpc
,       hxc_time_category_comps tcc
WHERE	tcc.time_category_id = p_time_category_id AND
        tcc.type = 'MC'
AND
        mpc.mapping_component_id (+) = tcc.component_type_id
AND
        bbit.bld_blk_info_type_id (+) = mpc.bld_blk_info_type_id;

CURSOR csr_get_alternate_name_comps ( p_alias_value_id NUMBER ) IS
SELECT
	bbit.bld_blk_info_type context
,	bbit.bld_blk_info_type_id
,	DECODE( bbit.bld_blk_info_type,
                'Dummy Cost Context',       REPLACE( mpc.segment, 'CostSegment',    'ATTRIBUTE' ),
                'Dummy Grp Context',        REPLACE( mpc.segment, 'GrpSegment',     'ATTRIBUTE' ),
                'Dummy Job Context',        REPLACE( mpc.segment, 'JobSegment',     'ATTRIBUTE' ),
                'Dummy Pos Context',        REPLACE( mpc.segment, 'PosSegment',     'ATTRIBUTE' ),
                'Dummy Paexpitdff Context', REPLACE( mpc.segment, 'PADFFAttribute', 'ATTRIBUTE' ),
		mpc.segment ) segment
,	mpc.name
,       atc.component_type application_column_name
,	av.attribute1
,	av.attribute2
,	av.attribute3
,	av.attribute4
,	av.attribute5
,	av.attribute6
,	av.attribute7
,	av.attribute8
,	av.attribute9
,	av.attribute10
,	av.attribute11
,	av.attribute12
,	av.attribute13
,	av.attribute14
,	av.attribute15
,	av.attribute16
,	av.attribute17
,	av.attribute18
,	av.attribute19
,	av.attribute20
,	av.attribute21
,	av.attribute22
,	av.attribute23
,	av.attribute24
,	av.attribute25
,	av.attribute26
,	av.attribute27
,	av.attribute28
,	av.attribute29
,	av.attribute30
FROM
	hxc_bld_blk_info_types bbit
,	hxc_mapping_components mpc
,	hxc_alias_type_components atc
,	hxc_alias_types hat
,	hxc_alias_definitions ad
,	hxc_alias_values av
WHERE
	av.alias_value_id = p_alias_value_id
AND
	ad.alias_definition_id = av.alias_definition_id
AND
	hat.alias_type_id = ad.alias_type_id
AND
	atc.alias_type_id = hat.alias_type_id
AND
	mpc.mapping_component_id = atc.mapping_component_id
AND
	bbit.bld_blk_info_type_id = mpc.bld_blk_info_type_id;


CURSOR csr_chk_tcc_sql_exists ( p_tcc_id NUMBER ) IS
SELECT time_category_comp_sql_id tcc_sql_id
FROM   hxc_time_category_comp_sql
WHERE  time_category_comp_id = p_tcc_id;

CURSOR csr_get_time_category ( p_time_category_id NUMBER ) IS
SELECT htc.time_sql
     , htc.operator
FROM   hxc_time_categories htc
WHERE  htc.time_category_id = p_time_category_id
AND EXISTS ( select 'x'
             from   hxc_time_category_comps tcc
             where  tcc.time_category_id = htc.time_category_id );

l_comps_r                 csr_get_category_comps%ROWTYPE;
l_alternate_name_comps_r  csr_get_alternate_name_comps%ROWTYPE;

TYPE l_comps_tab IS TABLE OF csr_get_category_comps%ROWTYPE INDEX BY BINARY_INTEGER;


PROCEDURE add_tc_to_cache ( p_time_category_id NUMBER
                          , p_time_category_info csr_get_time_category%ROWTYPE
                          , p_vs_comp_tab      t_vs_comp
                          , p_an_comp_tab      t_an_comp
                          , p_tc_comp_tab      t_tc_comp ) IS

l_proc 	varchar2(72);

l_tc_comp_ind PLS_INTEGER;

l_ind         PLS_INTEGER;

l_rec         hxc_tcc_shd.g_rec_type;

l_sql_string  CLOB;

l_start_index PLS_INTEGER;

CURSOR  csr_get_new_sql_string ( p_tcc_id NUMBER ) IS
SELECT	sql_string
FROM    hxc_time_category_comp_sql
WHERE   time_category_comp_id = p_tcc_id;

-- private function to check if the value set has been
-- changed since the TCC row was updated
-- If so populate and return l_rec

FUNCTION value_set_changed ( p_vs_comp_rec r_vs_comp
                           , p_rec IN OUT NOCOPY hxc_tcc_shd.g_rec_type )
RETURN BOOLEAN IS

CURSOR get_value_set_last_update_date ( p_flex_value_set_id NUMBER ) IS
SELECT vs.last_update_date
FROM   fnd_flex_value_sets vs
WHERE  vs.flex_value_set_id = p_flex_value_set_id;

CURSOR get_vset_tab_last_update_date ( p_flex_value_set_id NUMBER ) IS
SELECT vst.last_update_date
FROM   fnd_flex_validation_tables vst
WHERE  vst.flex_value_set_id = p_flex_value_set_id;

l_vs_last_update_date DATE;

l_proc 	varchar2(72);

BEGIN



IF ( g_debug ) THEN
l_proc := g_package||'value_set_changed';
hr_utility.set_location('Leaving '||l_proc, 10);
END IF;

OPEN  get_value_set_last_update_date ( p_vs_comp_rec.flex_value_set_id );
FETCH get_value_set_last_update_date INTO l_vs_last_update_date;
CLOSE get_value_set_last_update_date;

IF ( g_debug ) THEN
hr_utility.trace('Value set is '||to_char(p_vs_comp_rec.flex_value_set_id));
hr_utility.trace('Value set last update date is '||to_char(l_vs_last_update_date));
hr_utility.trace('TCC row last update date is '||to_char(p_vs_comp_rec.last_update_date));
END IF;

IF ( l_vs_last_update_date > p_vs_comp_rec.last_update_date )
THEN

	-- value set definition changed since time category comp
	-- created

	p_rec.time_category_comp_id := p_vs_comp_rec.time_category_comp_id;
        p_rec.time_category_id      := p_vs_comp_rec.time_category_id;
        p_rec.ref_time_category_id  := NULL;
        p_rec.component_type_id     := p_vs_comp_rec.component_type_id;
        p_rec.flex_value_set_id     := p_vs_comp_rec.flex_value_set_id;
        p_rec.value_id              := '<VALUE_SET_SQL>';
        p_rec.is_null               := p_vs_comp_rec.is_null;
        p_rec.equal_to              := p_vs_comp_rec.equal_to;
        p_rec.type                  := 'MC_VS';
        p_rec.object_version_number := NULL;

	RETURN TRUE;

ELSE

	-- check table last update date

	OPEN  get_vset_tab_last_update_date ( p_vs_comp_rec.flex_value_set_id );
	FETCH get_vset_tab_last_update_date INTO l_vs_last_update_date;
	CLOSE get_vset_tab_last_update_date;

IF ( g_debug ) THEN
	hr_utility.trace('Value set is '||to_char(p_vs_comp_rec.flex_value_set_id));
	hr_utility.trace('Value set table last update date is '||to_char(l_vs_last_update_date));
	hr_utility.trace('TCC row last update date is '||to_char(p_vs_comp_rec.last_update_date));
END IF;

	IF ( l_vs_last_update_date > p_vs_comp_rec.last_update_date )
	THEN

		-- value set definition changed since time category comp
		-- created

		p_rec.time_category_comp_id := p_vs_comp_rec.time_category_comp_id;
	        p_rec.time_category_id      := p_vs_comp_rec.time_category_id;
	        p_rec.ref_time_category_id  := NULL;
	        p_rec.component_type_id     := p_vs_comp_rec.component_type_id;
	        p_rec.flex_value_set_id     := p_vs_comp_rec.flex_value_set_id;
	        p_rec.value_id              := '<VALUE_SET_SQL>';
	        p_rec.is_null               := p_vs_comp_rec.is_null;
	        p_rec.equal_to              := p_vs_comp_rec.equal_to;
	        p_rec.type                  := 'MC_VS';
	        p_rec.object_version_number := NULL;

		RETURN TRUE;

	ELSE

		RETURN FALSE;

	END IF;

END IF;

IF ( g_debug ) THEN
hr_utility.set_location('Leaving '||l_proc, 10);
END IF;

END value_set_changed;


BEGIN -- add_tc_to_cache



IF ( g_debug ) THEN
l_proc := g_package||'add_tc_to_cache';
hr_utility.set_location('Entering '||l_proc, 10);
END IF;

l_start_index := NVL( g_tc_component_cache.LAST, 0 )+1;
g_tc_cache( p_time_category_id ).time_sql    := p_time_category_info.time_sql;
g_tc_cache( p_time_category_id ).operator    := p_time_category_info.operator;
g_tc_cache( p_time_category_id ).cache_date  := sysdate;

-- this is quite straight forward other than having to check that
-- the value set associated with the MC_VS has not changed since
-- the MC_VS row was last updated.

IF ( p_vs_comp_tab.COUNT > 0 )
THEN

	g_tc_cache( p_time_category_id ).start_index := l_start_index;

	FOR x IN p_vs_comp_tab.FIRST .. p_vs_comp_tab.LAST
	LOOP

		l_tc_comp_ind := NVL( g_tc_component_cache.LAST, 0 )+1;

		IF ( value_set_changed ( p_vs_comp_tab(x), l_rec ) )
		THEN

			-- re-evaluate

			IF ( g_debug ) THEN
			hr_utility.trace('Value Set Changed!!!');
			END IF;

                        update_time_category_comp_sql ( p_rec        => l_rec );

			-- touch tcc row

			UPDATE hxc_time_category_comps tcc
                        SET    time_category_comp_id = l_rec.time_category_comp_id
                        WHERE  time_category_comp_id = l_rec.time_category_comp_id;

			OPEN  csr_get_new_sql_string ( l_rec.time_category_comp_id );
			FETCH csr_get_new_sql_string INTO l_sql_string;
			CLOSE csr_get_new_sql_string;

			g_tc_component_cache(l_tc_comp_ind).sql_string := l_sql_string;

		ELSE

			IF ( g_debug ) THEN
			hr_utility.trace('Value Set Not Changed');
			END IF;

			g_tc_component_cache(l_tc_comp_ind).sql_string := p_vs_comp_tab(x).sql_string;

		END IF;

		g_tc_component_cache(l_tc_comp_ind).type       := 'MC_VS';

	END LOOP;

END IF; -- IF ( p_vs_comp_tab.COUNT > 0 )


IF ( p_an_comp_tab.COUNT > 0 )
THEN

	g_tc_cache( p_time_category_id ).start_index := l_start_index;

	-- now cache the Alternate Name Components

	FOR x IN p_an_comp_tab.FIRST .. p_an_comp_tab.LAST
	LOOP

		l_tc_comp_ind := NVL( g_tc_component_cache.LAST, 0 )+1;

		g_tc_component_cache(l_tc_comp_ind).sql_string := p_an_comp_tab(x).sql_string;
		g_tc_component_cache(l_tc_comp_ind).type       := 'AN';

	END LOOP;

END IF; -- IF ( p_an_comp_tab.COUNT > 0 )


IF ( p_tc_comp_tab.COUNT > 0 )
THEN

	g_tc_cache( p_time_category_id ).start_index := l_start_index;

	-- now cache the Time Category Components

	FOR x IN p_tc_comp_tab.FIRST .. p_tc_comp_tab.LAST
	LOOP

		l_tc_comp_ind := NVL( g_tc_component_cache.LAST, 0 )+1;

		g_tc_component_cache(l_tc_comp_ind).ref_tc_id := p_tc_comp_tab(x).ref_tc_id;
		g_tc_component_cache(l_tc_comp_ind).type      := 'TC';

	END LOOP;

END IF; -- IF ( p_tc_comp_tab.COUNT > 0 )

IF ( g_tc_cache(p_time_category_id).start_index IS NOT NULL )
THEN

	g_tc_cache( p_time_category_id ).stop_index := l_tc_comp_ind;

END IF;

IF ( g_debug ) THEN
hr_utility.set_location('Leaving '||l_proc, 100);

hr_utility.trace('TC Cache for '||to_char(p_time_category_id));

hr_utility.trace('g_tc_cache operator  is '||g_tc_cache(p_time_category_id).operator);
hr_utility.trace('g_tc_cache start     is '||to_char(g_tc_cache(p_time_category_id).start_index));
hr_utility.trace('g_tc_cache stop      is '||to_char(g_tc_cache(p_time_category_id).stop_index));
hr_utility.trace(SUBSTR( 'g_tc_cache time sql  is '||g_tc_cache(p_time_category_id).time_sql,1,250));


IF ( g_tc_cache(p_time_category_id).start_index IS NOT NULL )
THEN

hr_utility.trace('TC Cache components are ');

FOR x IN g_tc_cache(p_time_category_id).start_index ..
         g_tc_cache(p_time_category_id).stop_index
LOOP

	hr_utility.trace('Type       is '||g_tc_component_cache(x).type);
	hr_utility.trace('ref tc id  is '||to_char(g_tc_component_cache(x).ref_tc_id));

END LOOP;

ELSE

	hr_utility.trace('No components');

END IF;
END IF; -- g_debug

END add_tc_to_cache;



PROCEDURE get_tc_from_cache ( p_time_category_id NUMBER
                            , p_vs_comp_tab      IN OUT NOCOPY t_vs_comp
                            , p_an_comp_tab      IN OUT NOCOPY t_an_comp
                            , p_tc_comp_tab      IN OUT NOCOPY t_tc_comp ) IS

l_proc 	varchar2(72);

l_vs_ind PLS_INTEGER := 1;
l_tc_ind PLS_INTEGER := 1;
l_an_ind PLS_INTEGER := 1;

l_tc_cache_start PLS_INTEGER;
l_tc_cache_stop  PLS_INTEGER;

BEGIN



IF ( g_debug ) THEN
l_proc := g_package||'get_tc_from_cache';
hr_utility.set_location('Entering '||l_proc, 10);

hr_utility.trace('Getting info from cache for TC '||to_char(p_time_category_id));

END IF;

l_tc_cache_start := g_tc_cache(p_time_category_id).start_index;
l_tc_cache_stop  := g_tc_cache(p_time_category_id).stop_index;

IF ( l_tc_cache_start IS NOT NULL )
THEN

	IF ( g_debug ) THEN
	hr_utility.trace('Cache components exist');
	END IF;

	FOR x IN l_tc_cache_start .. l_tc_cache_stop
	LOOP

		IF ( g_tc_component_cache(x).type = 'MC_VS' )
		THEN
			p_vs_comp_tab(l_vs_ind).sql_string := g_tc_component_cache(x).sql_string;

			l_vs_ind := l_vs_ind + 1;

		ELSIF ( g_tc_component_cache(x).type = 'AN' )
		THEN
			p_an_comp_tab(l_an_ind).sql_string := g_tc_component_cache(x).sql_string;

			l_an_ind := l_an_ind + 1;

		ELSIF ( g_tc_component_cache(x).type = 'TC' )
		THEN
			p_tc_comp_tab(l_tc_ind).ref_tc_id := g_tc_component_cache(x).ref_tc_id;

			l_tc_ind := l_tc_ind + 1;

		ELSE
	                    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
	                    fnd_message.set_token('PROCEDURE', l_proc);
	                    fnd_message.set_token('STEP','Invalid TYPE');
	                    fnd_message.raise_error;
		END IF;

	END LOOP;

ELSE

	IF ( g_debug ) THEN
	hr_utility.trace('No Cache Components');
	END IF;

END IF;

IF ( g_debug ) THEN
hr_utility.set_location('Leaving '||l_proc, 20);
END IF;

END get_tc_from_cache;


FUNCTION tc_cache_exists ( p_time_category_id NUMBER ) RETURN BOOLEAN IS

BEGIN



	IF ( g_tc_cache.EXISTS ( p_time_category_id ) )
	THEN

		IF ( g_debug ) THEN
		hr_utility.trace('TC cache exists');
		END IF;

		-- is cache more than 30 mins old?

-- 10 mins	IF ( ( sysdate - g_tc_cache(p_time_category_id).cache_date ) <= .007 )
		IF ( ( sysdate - g_tc_cache(p_time_category_id).cache_date ) <= .02 )
		THEN
			IF ( g_debug ) THEN
			hr_utility.trace('TC Cache Current');
			END IF;

			RETURN TRUE;
		ELSE
			IF ( g_debug ) THEN
			hr_utility.trace('TC Cache Expired');
			END IF;

			g_tc_cache.DELETE;
			g_tc_bb_ok_cache.DELETE;

			RETURN FALSE;
		END IF;
	ELSE

		IF ( g_debug ) THEN
		hr_utility.trace('TC Cache does not exist');
		END IF;

		RETURN FALSE;
	END IF;

END tc_cache_exists;


FUNCTION get_bb_ok_tab_from_string ( p_time_category_id NUMBER ) RETURN t_tc_bb_ok

IS

l_bb_ok_string VARCHAR2(32000);
l_bb_ok_tab    t_tc_bb_ok;
l_bb_id        NUMBER;

l_proc 	varchar2(72);

BEGIN



IF ( g_debug ) THEN
	l_proc := g_package||'get_bb_ok_tab_from_string';
	hr_utility.set_location('Entering '||l_proc, 10);
END IF;

l_bb_ok_string := g_tc_bb_ok_cache(p_time_category_id).bb_ok_string;

WHILE l_bb_ok_string IS NOT NULL
LOOP

    IF ( INSTR( l_bb_ok_string, ',' ) = 0 )
    THEN

         l_bb_id := RTRIM(LTRIM(l_bb_ok_string));

         l_bb_ok_tab(l_bb_id).bb_id_ok := 'Y';

         l_bb_ok_string := REPLACE( l_bb_ok_string, l_bb_ok_string );

    ELSE

         l_bb_id := SUBSTR( l_bb_ok_string, 1, ( INSTR( l_bb_ok_string, ',' )-1) );

         l_bb_ok_tab(l_bb_id).bb_id_ok := 'Y';

         l_bb_ok_string := REPLACE( l_bb_ok_string, l_bb_id||', ' );

    END IF;

END LOOP;

IF ( g_debug ) THEN
	hr_utility.set_location('Leaving '||l_proc, 20);
END IF;

RETURN l_bb_ok_tab;

END get_bb_ok_tab_from_string;

--
-- private procedure
--
function get_token(
    the_list  varchar2,
    the_index number,
    delim     varchar2 := ','
)
    return    varchar2
is
    start_pos number;
    end_pos   number;
begin
    if the_index = 1 then
        start_pos := 1;
    else
        start_pos := instr(the_list,delim,1,the_index - 1);
        if start_pos = 0 then
            return null;
        else
            start_pos := start_pos + length(delim);
        end if;
    end if;

    end_pos := instr(the_list,delim,start_pos,1);

    if end_pos = 0 then
        return substr(the_list,start_pos);
    else
        return substr(the_list,start_pos,end_pos - start_pos);
    end if;

end get_token;

--
-- private procedure
--
FUNCTION get_token_count(
    the_list  varchar2,
    delim     varchar2 := ','
)
    return    number

is

l_result varchar2(30):= 'not null';
l_index  number :=1;
l_count  number :=0;


BEGIN
   WHILE l_result is not null
    LOOP
     l_result:= get_token (the_list,l_index,delim);
     l_index := l_index + 1;
     l_count := l_count + 1;
   END LOOP;

return l_count-1;

end get_token_count;

--
-- private procedure
--
function get_token_string(
    the_list  varchar2,
    delim     varchar2 := ','
)
    return    varchar2

is

l_result varchar2(32000);


BEGIN

FOR i in 1..get_token_count(the_list,',') LOOP
 if (i=1) then
    l_result := ':'||i;
 else
    l_result := l_result||',:'||i;
 end if;
END LOOP;
return l_result;

end get_token_string;


--
-- PRIVATE FUNCTION
--

FUNCTION parse_time_sql_to_bind(p_time_sql  VARCHAR2)
RETURN VARCHAR2  IS

l_bind_time_sql varchar2(32000);
l_between_or  varchar2(32000) := 'not null';
l_before_and varchar2(32000);
l_after_and varchar2(32000);
l_before_equal1 varchar2(32000);
l_before_equal2 varchar2(32000);

-- Bug 8589919
-- Changed the index to start from 1000.
-- There are two sets of indexes, one for attributes one for blk bind variables.
-- Initially blocks were to start from 1, increment by 1.
-- Attributes to start by 100, increment by 100.
-- No problem as long as there are no 100 blks, where there would be a clash.
-- Bug 7432755 reported this issue, and the fix was to change the attribute
-- indexes to start from 1000, step by 1000.
-- This causes the bind variables to pass above ~65k which is the allowed semantic
-- limit for plsql.  Issue raised for Apps IT in bug 8589919.
-- Fixed it by holding the blk index as such, and attribute index to start from 1000,
-- and step by 5.
l_index  number :=1000;

l_null BOOLEAN := FALSE;
l_pass BOOLEAN := FALSE;

BEGIN


 WHILE l_between_or is not null
    LOOP
      l_between_or := get_token (p_time_sql,l_index,' OR ');

      IF (l_between_or IS NOT NULL AND  get_token (l_between_or,3,' AND ') IS NULL) THEN
        -- now I look for the and
        l_before_and := get_token (l_between_or,1,' AND ');
        l_after_and  := get_token (l_between_or,2,' AND ');

        -- now I can replace the value with the bind
        l_before_equal1 := get_token (l_before_and,1,'=');
        -- Bug 8589919
        l_before_equal1 := l_before_equal1 ||'=:'||l_index;

        -- now I can replace the value with the bind
        IF (instr(l_after_and,'IS NOT NULL') = 0 AND  instr(l_after_and,'IS NULL') = 0
        	AND  instr(l_after_and,'<>') = 0 AND instr(l_after_and,'IN') = 0)
        THEN
          l_before_equal2 := get_token (l_after_and,1,'=');
          -- Bug 8589919
          --l_before_equal2 := l_before_equal2 ||'=:'||((l_index*1000)+1)||')';
          l_before_equal2 := l_before_equal2 ||'=:'||((l_index)+1)||')';
          l_null := FALSE;
        ELSE
          l_before_equal2 := l_after_and;
	  l_null := TRUE;
        END IF;

        IF l_bind_time_sql IS NULL THEN
          l_bind_time_sql  := l_before_equal1 ||' AND '|| l_before_equal2 ;
        ELSE
          l_bind_time_sql  := l_bind_time_sql ||' OR '||l_before_equal1 ||' AND '|| l_before_equal2;
        END IF;
        l_pass := TRUE;
      ELSE
        IF l_bind_time_sql IS NULL THEN
          l_bind_time_sql := p_time_sql;
        ELSIF (l_null=FALSE AND l_pass = TRUE) THEN
          l_bind_time_sql  := l_bind_time_sql ||' )';
        END IF;

        l_pass := FALSE;
      END IF;

     -- Bug 8589919
     l_index := l_index + 5;

   END LOOP;

return l_bind_time_sql;

END parse_time_sql_to_bind;



PROCEDURE validate_time_category_sql ( p_sql_string IN LONG ) IS

l_sql   LONG := 'select distinct ta.bb_id from hxc_tmp_atts ta where ';

t_bb_id dbms_sql.Number_Table;

l_csr          INTEGER;
l_rows_fetched INTEGER;
l_dummy        INTEGER;

l_parse_time_sql VARCHAR2(32000);


l_between_or  varchar2(32000) := 'not null';
l_before_and varchar2(32000);
l_after_and varchar2(32000);
l_before_equal1 varchar2(32000);
l_before_equal2 varchar2(32000);

-- Bug 8589919
l_index  number :=1000;





BEGIN

-- the SQL MUST returns rows to show all possible errors
-- particularly implicit character to number and vice
-- versa

INSERT INTO hxc_tmp_atts (
      ta_id
,     bb_id
,     attribute1
,     attribute2
,     attribute3
,     attribute4
,     attribute5
,     attribute6
,     attribute7
,     attribute8
,     attribute9
,     attribute10
,     attribute11
,     attribute12
,     attribute13
,     attribute14
,     attribute15
,     attribute16
,     attribute17
,     attribute18
,     attribute19
,     attribute20
,     attribute21
,     attribute22
,     attribute23
,     attribute24
,     attribute25
,     attribute26
,     attribute27
,     attribute28
,     attribute29
,     attribute30
,     bld_blk_info_type_id
,     attribute_category )
VALUES (
      1
,     2
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     'Dummy'
,     1
,     'Dummy' );

  l_parse_time_sql := parse_time_sql_to_bind(p_sql_string);

  l_sql   := 'select distinct ta.bb_id from hxc_tmp_atts ta where '||l_parse_time_sql;

  BEGIN
   l_rows_fetched := 100;

   l_csr := dbms_sql.open_cursor;

   dbms_sql.parse ( l_csr, l_sql, dbms_sql.native );

   -- replace the parse_time_sql bind
   WHILE l_between_or is not null
    LOOP
     l_between_or := get_token (p_sql_string,l_index,' OR ');

     IF (l_between_or IS NOT NULL  AND  get_token (l_between_or,3,' AND ') IS NULL) THEN
       -- now I look for the and
       l_before_and := get_token (l_between_or,1,'AND');
       l_after_and  := get_token (l_between_or,2,'AND');

       -- now I can replace the value with the bind
       l_before_equal1 := replace(get_token (l_before_and,2,'='),')','');
       l_before_equal1 := trim(replace(l_before_equal1,'''',''));
       -- Bug 8589919
       --dbms_sql.bind_variable( l_csr, ':'||l_index*1000, l_before_equal1 );
       dbms_sql.bind_variable( l_csr, ':'||l_index, l_before_equal1 );

       IF (instr(l_after_and,'IS NOT NULL') = 0 AND  instr(l_after_and,'IS NULL') = 0
       		AND  instr(l_after_and,'<>') = 0 AND  instr(l_after_and,'IN') = 0)
       THEN

       -- now I can replace the value with the bind
       l_before_equal2 := replace(get_token (l_after_and,2,'='),')','');
       l_before_equal2 := trim(replace(l_before_equal2,'''',''));

       -- Bug 8589919
       dbms_sql.bind_variable( l_csr, ':'||((l_index)+1),l_before_equal2);

       END IF;

      END IF;
      -- Bug 8589919
      l_index := l_index + 5;

   END LOOP;

   dbms_sql.define_array (
		c		=> l_csr
	,	position	=> 1
	,	n_tab		=> t_bb_id
	,	cnt		=> l_rows_fetched
	,	lower_bound	=> 1 );

	l_dummy	:=	dbms_sql.execute ( l_csr );

	-- loop to ensure we fetch all the rows

    WHILE ( l_rows_fetched = 100 )
	LOOP

		l_rows_fetched	:=	dbms_sql.fetch_rows ( l_csr );

		IF ( l_rows_fetched > 0 )
		THEN

			dbms_sql.column_value (
				c		=> l_csr
			,	position	=> 1
			,	n_tab		=> t_bb_id );

		t_bb_id.DELETE;

		END IF;

	END LOOP;

	dbms_sql.close_cursor ( l_csr );

--		execute immediate l_sql INTO l_dummy;

	EXCEPTION WHEN NO_DATA_FOUND THEN

		null;

		WHEN OTHERS THEN

                fnd_message.set_name('HXC', 'HXC_HTC_INVALID_SQL');
                fnd_message.set_token('ERROR', SQLERRM );
                fnd_message.raise_error;

	END;

END validate_time_category_sql;



PROCEDURE chk_profile_flex ( p_flex_value_set_id NUMBER
                            ,p_where        OUT NOCOPY LONG
                            ,p_sql_ok       OUT NOCOPY BOOLEAN  ) IS

l_proc 	varchar2(72) := g_package||'chk_profile_flex';

l_sql    LONG;
l_sql_ok BOOLEAN := FALSE;

CURSOR csr_get_value_set_sql IS
SELECT additional_where_clause
FROM   fnd_flex_validation_tables
WHERE  flex_value_set_id = p_flex_value_set_id;

BEGIN

OPEN  csr_get_value_set_sql;
FETCH csr_get_value_set_sql INTO l_sql;
CLOSE csr_get_value_set_sql;


IF ((( INSTR(UPPER(l_sql),':$FLEX$')     = 0 ) AND
     ( INSTR(UPPER(l_sql),'$FLEX$')      = 0 ) AND
     ( INSTR(UPPER(l_sql),'$PROFILE$')   = 0 ) AND
     ( INSTR(UPPER(l_sql),':$PROFILE$')  = 0 ) AND
     ( INSTR(UPPER(l_sql),'$PROFILES$')  = 0 ) AND
     ( INSTR(UPPER(l_sql),':$PROFILES$') = 0 )) OR l_sql IS NULL )
THEN

	l_sql_ok := TRUE;

END IF;

p_where  := l_sql;
p_sql_ok := l_sql_ok;

END chk_profile_flex;



FUNCTION continue_evaluation ( p_operator VARCHAR2
                             , p_tc_bb_ok_string VARCHAR2
                             , p_tc_bb_not_ok_string VARCHAR2 ) RETURN BOOLEAN IS

l_return BOOLEAN := TRUE;

BEGIN



IF ( p_operator = 'OR' )
THEN

	IF ( p_tc_bb_not_ok_string IS NULL )
	THEN
		l_return := FALSE;
	END IF;

ELSE -- p_operator = 'AND'

	IF ( p_tc_bb_ok_string IS NULL )
	THEN
		l_return := FALSE;
	END IF;

END IF;

IF ( l_return )
THEN
	IF ( g_debug ) THEN
		hr_utility.trace('Continue evaluation is TRUE');
	END IF;
ELSE
	IF ( g_debug ) THEN
		hr_utility.trace('Continue evaluation is FALSE');
	END IF;
END IF;

RETURN l_return;

END continue_evaluation;



PROCEDURE get_dyn_sql ( p_time_sql IN OUT NOCOPY LONG
                      , p_comps_r  IN            csr_get_category_comps%ROWTYPE
                      , p_operator IN            VARCHAR2
                      , p_an_sql   IN            BOOLEAN DEFAULT FALSE
                      , p_vs_sql   IN            BOOLEAN DEFAULT FALSE ) IS

l_proc      varchar2(72);
l_dyn_sql     LONG;
l_ref_dyn_sql LONG;

l_value_string VARCHAR2(150);
l_string_start  VARCHAR2(30) := '( ta.bld_blk_info_type_id = ';
l_string_and    VARCHAR2(10)  := ' AND ta.';


BEGIN



IF ( g_debug ) THEN
	l_proc := g_package||'get_dyn_sql';
	hr_utility.trace('get dyn sql params are ....');
	hr_utility.trace('dyn sql is '||p_time_sql);
END IF;

-- we want the dynamic sql string

l_dyn_sql := p_time_sql;

l_ref_dyn_sql := NULL;

IF ( p_comps_r.context = 'Dummy Element Context' AND p_comps_r.flex_value_set_id = -1 AND
     p_comps_r.value_id <> '<WILDCARD>' )
THEN

	l_value_string := 'ELEMENT - '||p_comps_r.value_id;

ELSE

	l_value_string := p_comps_r.value_id;

END IF;


IF ( l_first_time_round )
THEN

-- set string for an sql

IF ( p_an_sql )
THEN
	l_string_and := ' AND ( ta.';
END IF;

	IF ( p_comps_r.segment IS NOT NULL )
	THEN

		IF ( ( l_value_string = '<WILDCARD>' ) AND ( p_comps_r.equal_to = 'Y' ) )
		THEN
			IF ( p_an_sql )
			THEN
		               	l_dyn_sql := l_dyn_sql
		                             ||l_string_start||p_comps_r.bld_blk_info_type_id
		                             ||l_string_and  ||p_comps_r.segment
		                             ||' IS NOT NULL ';
			ELSE
		               	l_dyn_sql := l_dyn_sql
		                             ||l_string_start||p_comps_r.bld_blk_info_type_id
		                             ||l_string_and  ||p_comps_r.segment
		                             ||' IS NOT NULL )';
			END IF;

		ELSIF ( ( l_value_string = '<WILDCARD>' ) AND ( p_comps_r.equal_to = 'N' ) )
		THEN

			IF ( g_debug ) THEN
				hr_utility.trace('GAZ - INVALID COMBO');
			END IF;

                    fnd_message.set_name('HXC', 'HXC_TC_INV_EQUAL_IS_NULL_COMBO');
		    fnd_message.raise_error;

		ELSIF ( ( l_value_string = '<IS NULL>' ) AND ( p_comps_r.equal_to = 'Y' ) )
		THEN
			IF ( p_an_sql )
			THEN
		               	l_dyn_sql := l_dyn_sql
		                             ||l_string_start||p_comps_r.bld_blk_info_type_id
		                             ||l_string_and  ||p_comps_r.segment
		                             ||' IS NULL ';
			ELSE
		               	l_dyn_sql := l_dyn_sql
		                             ||l_string_start||p_comps_r.bld_blk_info_type_id
		                             ||l_string_and  ||p_comps_r.segment
		                             ||' IS NULL )';
			END IF;

		ELSIF ( ( l_value_string = '<IS NULL>' ) AND ( p_comps_r.equal_to = 'N' ) )
		THEN
			IF ( p_an_sql )
			THEN
		               	l_dyn_sql := l_dyn_sql
		                             ||l_string_start||p_comps_r.bld_blk_info_type_id
		                             ||l_string_and  ||p_comps_r.segment
		                             ||' IS NOT NULL ';
			ELSE
		               	l_dyn_sql := l_dyn_sql
		                             ||l_string_start||p_comps_r.bld_blk_info_type_id
		                             ||l_string_and  ||p_comps_r.segment
		                             ||' IS NOT NULL )';
			END IF;

		ELSIF ( p_comps_r.equal_to = 'Y' )
		THEN
			IF ( p_an_sql )
			THEN
				l_dyn_sql := l_dyn_sql
		                             ||l_string_start||p_comps_r.bld_blk_info_type_id
		                             ||l_string_and  ||p_comps_r.segment
		                             ||' = '''||l_value_string||''' ';
			ELSIF ( p_vs_sql )
			THEN
				l_dyn_sql := l_dyn_sql
		                             ||l_string_start||p_comps_r.bld_blk_info_type_id
		                             ||l_string_and  ||p_comps_r.segment
		                             ||' IN ( '||l_value_string||' ) ';
			ELSE
				l_dyn_sql := l_dyn_sql
		                             ||l_string_start||p_comps_r.bld_blk_info_type_id
		                             ||l_string_and  ||p_comps_r.segment
		                             ||' = '''||l_value_string||''' )';
			END IF;
		ELSE
			IF ( p_an_sql )
			THEN
				l_dyn_sql := l_dyn_sql
		                             ||l_string_start||p_comps_r.bld_blk_info_type_id
		                             ||l_string_and  ||p_comps_r.segment
		                             ||' <> '''||l_value_string||''' ';
			ELSIF ( p_vs_sql )
			THEN
				l_dyn_sql := l_dyn_sql
		                             ||l_string_start||p_comps_r.bld_blk_info_type_id
		                             ||l_string_and  ||p_comps_r.segment
		                             ||' NOT IN ( '||l_value_string||' ) ';
			ELSE
				l_dyn_sql := l_dyn_sql
		                             ||l_string_start||p_comps_r.bld_blk_info_type_id
		                             ||l_string_and  ||p_comps_r.segment
		                             ||' <> '''||l_value_string||''' )';
			END IF;
		END IF;

	ELSE

		-- Ignore these TC components
		-- EAch Time Category SQL to be evaluated seperately from
		-- now on so combining of TIME_SQL not necessary

		IF ( g_debug ) THEN
			hr_utility.trace('GAZ - another TC !!!!');
		END IF;

	END IF;

ELSE

IF ( g_debug ) THEN
	hr_utility.trace('not first time round');
	hr_utility.trace('sql is '||l_dyn_sql);
END IF;

-- set l_string_start for the case when generating SQL for alernate name


	IF ( p_comps_r.segment IS NOT NULL )
	THEN

		IF ( ( l_value_string = '<WILDCARD>' ) AND ( p_comps_r.equal_to = 'Y' ) )
		THEN

			IF ( p_an_sql )
			THEN
		               	l_dyn_sql := l_dyn_sql||' '||p_operator||' ta.'
		                             ||p_comps_r.segment||' IS NOT NULL ';

			ELSE
		               	l_dyn_sql := l_dyn_sql||' '||p_operator||' '
		                             ||l_string_start||p_comps_r.bld_blk_info_type_id
		                             ||l_string_and  ||p_comps_r.segment
		                             ||' IS NOT NULL )';
			END IF;

		ELSIF ( ( l_value_string = '<WILDCARD>' ) AND ( p_comps_r.equal_to = 'N' ) )
		THEN

			IF ( g_debug ) THEN
				hr_utility.trace('GAZ - INVALID COMBO');
			END IF;

                    fnd_message.set_name('HXC', 'HXC_TC_INV_EQUAL_IS_NULL_COMBO');
		    fnd_message.raise_error;

		ELSIF ( ( l_value_string = '<IS NULL>' ) AND ( p_comps_r.equal_to = 'Y' ) )
		THEN

			IF ( p_an_sql )
			THEN
		               	l_dyn_sql := l_dyn_sql||' '||p_operator||' ta.'
		                             ||p_comps_r.segment||' IS NULL ';
			ELSE
		               	l_dyn_sql := l_dyn_sql||' '||p_operator||' '
		                             ||l_string_start||p_comps_r.bld_blk_info_type_id
		                             ||l_string_and  ||p_comps_r.segment
		                             ||' IS NULL )';
			END IF;

		ELSIF ( ( l_value_string = '<IS NULL>' ) AND ( p_comps_r.equal_to = 'N' ) )
		THEN

			IF ( p_an_sql )
			THEN
		               	l_dyn_sql := l_dyn_sql||' '||p_operator||' ta.'
		                             ||p_comps_r.segment||' IS NOT NULL ';
			ELSE
		               	l_dyn_sql := l_dyn_sql||' '||p_operator||' '
		                             ||l_string_start||p_comps_r.bld_blk_info_type_id
		                             ||l_string_and  ||p_comps_r.segment
		                             ||' IS NOT NULL )';
			END IF;

		ELSIF ( p_comps_r.equal_to = 'Y' )
		THEN

			IF ( p_an_sql )
			THEN
/* Changes made for the bug 5475464
				l_dyn_sql := l_dyn_sql||' '||p_operator||' ta.' */
				l_dyn_sql := l_dyn_sql||' AND ta.'
/* Changes made for the bug 5475464 */
		                             ||p_comps_r.segment||' = '''||l_value_string||''' ';
			ELSE
				l_dyn_sql := l_dyn_sql||' '||p_operator||' '
		                             ||l_string_start||p_comps_r.bld_blk_info_type_id
		                             ||l_string_and  ||p_comps_r.segment
		                             ||' = '''||l_value_string||''' )';
			END IF;
		ELSE

			IF ( p_an_sql )
			THEN
/* Changes made for the bug 5475464
				l_dyn_sql := l_dyn_sql||' '||p_operator||' ta.' */
				l_dyn_sql := l_dyn_sql||' AND ta.'
/* Changes made for the bug 5475464 */
		                             ||p_comps_r.segment||' <> '''||l_value_string||''' ';
			ELSE
				l_dyn_sql := l_dyn_sql||' '||p_operator||' '
		                             ||l_string_start||p_comps_r.bld_blk_info_type_id
		                             ||l_string_and  ||p_comps_r.segment
		                             ||' <> '''||l_value_string||''' )';
			END IF;
		END IF;

	ELSE

		-- Ignore these TC components
		-- EAch Time Category SQL to be evaluated seperately from
		-- now on so combining of TIME_SQL not necessary

		IF ( g_debug ) THEN
			hr_utility.trace('GAZ - another TC !!!!');
		END IF;

	END IF;
END IF;

IF ( g_debug ) THEN
	hr_utility.trace('dyn sql is '||l_dyn_sql);
END IF;

p_time_sql := l_dyn_sql;

END get_dyn_sql;


FUNCTION get_alternate_name_value ( p_alternate_name_comp_r csr_get_alternate_name_comps%ROWTYPE )
RETURN VARCHAR2 IS

l_return hxc_time_attributes.attribute1%TYPE;

BEGIN

IF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE1' )
THEN
	l_return := p_alternate_name_comp_r.attribute1;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE2' )
THEN
	l_return := p_alternate_name_comp_r.attribute2;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE3' )
THEN
	l_return := p_alternate_name_comp_r.attribute3;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE4' )
THEN
	l_return := p_alternate_name_comp_r.attribute4;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE5' )
THEN
	l_return := p_alternate_name_comp_r.attribute5;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE6' )
THEN
	l_return := p_alternate_name_comp_r.attribute6;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE7' )
THEN
	l_return := p_alternate_name_comp_r.attribute7;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE8' )
THEN
	l_return := p_alternate_name_comp_r.attribute8;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE9' )
THEN
	l_return := p_alternate_name_comp_r.attribute9;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE10' )
THEN
	l_return := p_alternate_name_comp_r.attribute10;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE11' )
THEN
	l_return := p_alternate_name_comp_r.attribute11;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE12' )
THEN
	l_return := p_alternate_name_comp_r.attribute12;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE13' )
THEN
	l_return := p_alternate_name_comp_r.attribute13;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE14' )
THEN
	l_return := p_alternate_name_comp_r.attribute14;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE15' )
THEN
	l_return := p_alternate_name_comp_r.attribute15;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE16' )
THEN
	l_return := p_alternate_name_comp_r.attribute16;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE17' )
THEN
	l_return := p_alternate_name_comp_r.attribute17;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE18' )
THEN
	l_return := p_alternate_name_comp_r.attribute18;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE19' )
THEN
	l_return := p_alternate_name_comp_r.attribute19;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE20' )
THEN
	l_return := p_alternate_name_comp_r.attribute20;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE21' )
THEN
	l_return := p_alternate_name_comp_r.attribute21;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE22' )
THEN
	l_return := p_alternate_name_comp_r.attribute22;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE23' )
THEN
	l_return := p_alternate_name_comp_r.attribute23;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE24' )
THEN
	l_return := p_alternate_name_comp_r.attribute24;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE25' )
THEN
	l_return := p_alternate_name_comp_r.attribute25;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE26' )
THEN
	l_return := p_alternate_name_comp_r.attribute26;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE27' )
THEN
	l_return := p_alternate_name_comp_r.attribute27;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE28' )
THEN
	l_return := p_alternate_name_comp_r.attribute28;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE29' )
THEN
	l_return := p_alternate_name_comp_r.attribute29;

ELSIF ( p_alternate_name_comp_r.application_column_name = 'ATTRIBUTE30' )
THEN
	l_return := p_alternate_name_comp_r.attribute30;

END IF;

RETURN l_return;

END get_alternate_name_value;




PROCEDURE mapping_component_string ( p_time_category_id NUMBER
                                   , p_time_sql	    IN OUT NOCOPY LONG ) IS

 l_proc      varchar2(72);

l_dynamic_sql	LONG;
l_ref_dyn_sql	LONG;


BEGIN -- mapping_component_string

g_debug := hr_utility.debug_enabled;

l_first_time_round := TRUE;

-- ***************************************
--       MAPPING_COMPONENT_STRING
-- ***************************************

IF ( g_debug ) THEN
	l_proc := g_package||'mapping_component_string';
	hr_utility.set_location('Processing '||l_proc, 10);

	hr_utility.trace('Time Category ID is '||to_char(p_time_category_id));
END IF;

-- get the time category operator

OPEN  csr_get_operator ( p_time_category_id);
FETCH csr_get_operator INTO l_operator;
CLOSE csr_get_operator;

-- check for cached value first

-- maintain index value

OPEN	csr_get_category_comps ( p_time_category_id );
FETCH	csr_get_category_comps INTO l_comps_r;

IF ( g_debug ) THEN
	hr_utility.set_location('Processing '||l_proc, 20);
END IF;

WHILE csr_get_category_comps%FOUND
LOOP

	IF ( g_debug ) THEN
		hr_utility.set_location('Processing '||l_proc, 30);
	END IF;

	get_dyn_sql ( p_time_sql => l_dynamic_sql
		    , p_comps_r  => l_comps_r
                    , p_operator => l_operator );

	IF ( g_debug ) THEN
		hr_utility.set_location('Processing '||l_proc, 60);
	END IF;

	FETCH	csr_get_category_comps INTO l_comps_r;

	l_first_time_round := FALSE;

END LOOP;

IF ( g_debug ) THEN
	hr_utility.set_location('Processing '||l_proc, 70);
END IF;

CLOSE csr_get_category_comps;

IF ( g_debug ) THEN
	hr_utility.set_location('Processing '||l_proc, 80);
END IF;

IF ( l_dynamic_sql IS NOT NULL )
THEN
	l_dynamic_sql := ' ( '||l_dynamic_sql||' ) ';

	validate_time_category_sql ( l_dynamic_sql );

END IF;

p_time_sql := l_dynamic_sql;

IF ( g_debug ) THEN
	hr_utility.trace('Final dyn sql is '||NVL(p_time_sql,'Empty'));
END IF;

END mapping_component_string;




PROCEDURE alternate_name_string ( p_alias_value_id NUMBER
                        ,         p_operator       VARCHAR2
			,         p_is_null        VARCHAR2
                        ,         p_equal_to       VARCHAR2
			,	  p_time_sql	    IN OUT NOCOPY LONG ) IS

 l_proc      varchar2(72);

l_dynamic_sql	LONG;
l_ref_dyn_sql	LONG;
l_ind           PLS_INTEGER := 1;

l_value hxc_time_attributes.attribute1%TYPE;

l_is_null VARCHAR2(20);

l_comps_t l_comps_tab;

l_first_context hxc_bld_blk_info_types.bld_blk_info_type%TYPE;

BEGIN -- alternate_name_string

g_debug := hr_utility.debug_enabled;

IF ( g_debug ) THEN
	l_proc := g_package||'alternate_name_string';
	hr_utility.set_location('Entering '||l_proc, 10);
END IF;

l_comps_t.DELETE;

l_first_time_round := TRUE;

-- ***************************************
--       ALTERNATE_NAME_STRING
-- ***************************************

IF ( g_debug ) THEN
	hr_utility.set_location('Processing '||l_proc, 20);
END IF;

OPEN	csr_get_alternate_name_comps ( p_alias_value_id );
FETCH	csr_get_alternate_name_comps INTO l_alternate_name_comps_r;

l_first_context := l_alternate_name_comps_r.context;

IF ( g_debug ) THEN
	hr_utility.set_location('Processing '||l_proc, 25);
END IF;

WHILE csr_get_alternate_name_comps%FOUND
LOOP

	IF ( g_debug ) THEN
		hr_utility.set_location('Processing '||l_proc, 30);
	END IF;

	l_value := get_alternate_name_value ( p_alternate_name_comp_r => l_alternate_name_comps_r );

	IF ( p_is_null = 'N' )
	THEN
		l_is_null := '<WILDCARD>';
	ELSE
		l_is_null := '<IS NULL>';
	END IF;

	l_comps_t(l_ind).context                   := l_alternate_name_comps_r.context;
	l_comps_t(l_ind).bld_blk_info_type_id      := l_alternate_name_comps_r.bld_blk_info_type_id;
	l_comps_t(l_ind).segment                   := l_alternate_name_comps_r.segment;
        l_comps_t(l_ind).value_id                  := NVL(l_value, l_is_null );
	l_comps_t(l_ind).ref_time_category_id      := -1; -- dummy value not used
	l_comps_t(l_ind).flex_value_set_id         := -1; -- dummy value not used
	l_comps_t(l_ind).equal_to                  := p_equal_to;

	IF ( g_debug ) THEN
		hr_utility.set_location('Processing '||l_proc, 60);
	END IF;

	FETCH	csr_get_alternate_name_comps INTO l_alternate_name_comps_r;

	l_ind := l_ind + 1;

	l_first_time_round := FALSE;

	-- Test to make sure that this alternate name is homogenous

	IF ( l_first_context <> l_alternate_name_comps_r.context )
	THEN
                    CLOSE csr_get_alternate_name_comps;

                    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
                    fnd_message.set_token('PROCEDURE', l_proc);
                    fnd_message.set_token('STEP','Alternate name component contexts different');
                    fnd_message.raise_error;
	END IF;

END LOOP;

IF ( g_debug ) THEN
	hr_utility.set_location('Processing '||l_proc, 70);
END IF;

CLOSE csr_get_alternate_name_comps;


-- Now we have a table of the alternate name components
-- Since the alternate name components must all have the context
-- the SQL required from get dyn sql is different

l_first_time_round := TRUE;

l_ind := l_comps_t.FIRST;

WHILE l_ind IS NOT NULL
LOOP

	get_dyn_sql ( p_time_sql => l_dynamic_sql
		    , p_comps_r  => l_comps_t(l_ind)
                    , p_operator => p_operator
                    , p_an_sql   => TRUE );

	l_ind := l_comps_t.NEXT(l_ind);

	l_first_time_round := FALSE;

END LOOP;

IF ( g_debug ) THEN
	hr_utility.set_location('Processing '||l_proc, 80);
END IF;

IF ( l_dynamic_sql IS NOT NULL )
THEN
	l_dynamic_sql := ' ( '||l_dynamic_sql||' ) ) )';
END IF;

p_time_sql := l_dynamic_sql;

IF ( g_debug ) THEN
	hr_utility.trace('alternate name sql is '||p_time_sql);
END IF;

END alternate_name_string;



PROCEDURE push_attributes ( p_attributes hxc_attribute_table_type ) IS


l_proc	VARCHAR2(72) := g_package||'push_attributes';

l_dummy VARCHAR2(1);

CURSOR csr_chk_bld_blks_not_empty IS
SELECT 'x'
FROM   dual
WHERE EXISTS ( select 'y'
from hxc_tmp_blks );

t_bb_id                tab_bb_id;
t_ta_id                tab_time_attribute_id;
t_attribute_category   tab_attribute_category;
t_attribute            tab_attribute;
t_attribute1           tab_attribute;
t_attribute2           tab_attribute;
t_attribute3           tab_attribute;
t_attribute4           tab_attribute;
t_attribute5           tab_attribute;
t_attribute6           tab_attribute;
t_attribute7           tab_attribute;
t_attribute8           tab_attribute;
t_attribute9           tab_attribute;
t_attribute10          tab_attribute;
t_attribute11          tab_attribute;
t_attribute12          tab_attribute;
t_attribute13          tab_attribute;
t_attribute14          tab_attribute;
t_attribute15          tab_attribute;
t_attribute16          tab_attribute;
t_attribute17          tab_attribute;
t_attribute18          tab_attribute;
t_attribute19          tab_attribute;
t_attribute20          tab_attribute;
t_attribute21          tab_attribute;
t_attribute22          tab_attribute;
t_attribute23          tab_attribute;
t_attribute24          tab_attribute;
t_attribute25          tab_attribute;
t_attribute26          tab_attribute;
t_attribute27          tab_attribute;
t_attribute28          tab_attribute;
t_attribute29          tab_attribute;
t_attribute30          tab_attribute;
t_bld_blk_info_type_id tab_bld_blk_info_type_id;

l_ind PLS_INTEGER;

x PLS_INTEGER := 0;


BEGIN

-- check to make sure bld blk not empty

OPEN  csr_chk_bld_blks_not_empty;
FETCH csr_chk_bld_blks_not_empty INTO l_dummy;

IF csr_chk_bld_blks_not_empty%NOTFOUND
THEN

	CLOSE csr_chk_bld_blks_not_empty;

	-- we did error here but on delete there are never
	-- going to be any blocks

ELSE

	CLOSE csr_chk_bld_blks_not_empty;

-- populate attribute array

l_ind := p_attributes.FIRST;

WHILE l_ind IS NOT NULL
LOOP
/* removed 'ALTERNATE NAME IDENTIFIERS' from the if condition as part of the fix to bug 5642255 */
	IF ( p_attributes(l_ind).attribute_category NOT IN
             ( 'TEMPLATES', 'SECURITY', 'REASON', 'LAYOUT', 'APPROVAL' ) )
	THEN

	x := x + 1;

	t_ta_id(x)                := p_attributes(l_ind).time_attribute_id;
	t_bb_id(x)                := p_attributes(l_ind).building_block_id;
	t_attribute_category(x)   := p_attributes(l_ind).attribute_category;
	t_bld_blk_info_type_id(x) := p_attributes(l_ind).bld_blk_info_type_id;
	t_attribute1(x)           := p_attributes(l_ind).attribute1;
	t_attribute2(x)           := p_attributes(l_ind).attribute2;
	t_attribute3(x)           := p_attributes(l_ind).attribute3;
	t_attribute4(x)           := p_attributes(l_ind).attribute4;
	t_attribute5(x)           := p_attributes(l_ind).attribute5;
	t_attribute6(x)           := p_attributes(l_ind).attribute6;
	t_attribute7(x)           := p_attributes(l_ind).attribute7;
	t_attribute8(x)           := p_attributes(l_ind).attribute8;
	t_attribute9(x)           := p_attributes(l_ind).attribute9;
	t_attribute10(x)           := p_attributes(l_ind).attribute10;
	t_attribute11(x)           := p_attributes(l_ind).attribute11;
	t_attribute12(x)           := p_attributes(l_ind).attribute12;
	t_attribute13(x)           := p_attributes(l_ind).attribute13;
	t_attribute14(x)           := p_attributes(l_ind).attribute14;
	t_attribute15(x)           := p_attributes(l_ind).attribute15;
	t_attribute16(x)           := p_attributes(l_ind).attribute16;
	t_attribute17(x)           := p_attributes(l_ind).attribute17;
	t_attribute18(x)           := p_attributes(l_ind).attribute18;
	t_attribute19(x)           := p_attributes(l_ind).attribute19;
	t_attribute20(x)           := p_attributes(l_ind).attribute20;
	t_attribute21(x)           := p_attributes(l_ind).attribute21;
	t_attribute22(x)           := p_attributes(l_ind).attribute22;
	t_attribute23(x)           := p_attributes(l_ind).attribute23;
	t_attribute24(x)           := p_attributes(l_ind).attribute24;
	t_attribute25(x)           := p_attributes(l_ind).attribute25;
	t_attribute26(x)           := p_attributes(l_ind).attribute26;
	t_attribute27(x)           := p_attributes(l_ind).attribute27;
	t_attribute28(x)           := p_attributes(l_ind).attribute28;
	t_attribute29(x)           := p_attributes(l_ind).attribute29;
	t_attribute30(x)           := p_attributes(l_ind).attribute30;

	END IF;

	l_ind := p_attributes.NEXT(l_ind);

END LOOP;

-- attribute insert

FORALL attx IN 1 .. x

INSERT INTO hxc_tmp_atts (
      ta_id
,     bb_id
,     attribute1
,     attribute2
,     attribute3
,     attribute4
,     attribute5
,     attribute6
,     attribute7
,     attribute8
,     attribute9
,     attribute10
,     attribute11
,     attribute12
,     attribute13
,     attribute14
,     attribute15
,     attribute16
,     attribute17
,     attribute18
,     attribute19
,     attribute20
,     attribute21
,     attribute22
,     attribute23
,     attribute24
,     attribute25
,     attribute26
,     attribute27
,     attribute28
,     attribute29
,     attribute30
,     bld_blk_info_type_id
,     attribute_category )
VALUES (
      t_ta_id(attx)
,     t_bb_id(attx)
,     t_attribute1(attx)
,     t_attribute2(attx)
,     t_attribute3(attx)
,     t_attribute4(attx)
,     t_attribute5(attx)
,     t_attribute6(attx)
,     t_attribute7(attx)
,     t_attribute8(attx)
,     t_attribute9(attx)
,     t_attribute10(attx)
,     t_attribute11(attx)
,     t_attribute12(attx)
,     t_attribute13(attx)
,     t_attribute14(attx)
,     t_attribute15(attx)
,     t_attribute16(attx)
,     t_attribute17(attx)
,     t_attribute18(attx)
,     t_attribute19(attx)
,     t_attribute20(attx)
,     t_attribute21(attx)
,     t_attribute22(attx)
,     t_attribute23(attx)
,     t_attribute24(attx)
,     t_attribute25(attx)
,     t_attribute26(attx)
,     t_attribute27(attx)
,     t_attribute28(attx)
,     t_attribute29(attx)
,     t_attribute30(attx)
,     t_bld_blk_info_type_id(attx)
,     t_attribute_category(attx) );

hxc_time_category_utils_pkg.g_master_tc_info_rec.attribute_count := x;

-- delete attribute array

t_bb_id.delete;
t_ta_id.delete;
t_bld_blk_info_type_id.delete;
t_attribute_category.delete;
t_attribute1.delete;
t_attribute2.delete;
t_attribute3.delete;
t_attribute4.delete;
t_attribute5.delete;
t_attribute6.delete;
t_attribute7.delete;
t_attribute8.delete;
t_attribute9.delete;
t_attribute10.delete;
t_attribute11.delete;
t_attribute12.delete;
t_attribute13.delete;
t_attribute14.delete;
t_attribute15.delete;
t_attribute16.delete;
t_attribute17.delete;
t_attribute18.delete;
t_attribute19.delete;
t_attribute20.delete;
t_attribute21.delete;
t_attribute22.delete;
t_attribute23.delete;
t_attribute24.delete;
t_attribute25.delete;
t_attribute26.delete;
t_attribute27.delete;
t_attribute28.delete;
t_attribute29.delete;
t_attribute30.delete;

END IF; -- IF csr_chk_bld_blks_not_empty%NOTFOUND

END push_attributes;


PROCEDURE push_attributes ( p_attributes hxc_self_service_time_deposit.building_block_attribute_info ) IS

l_attributes hxc_attribute_table_type;

BEGIN

l_attributes := hxc_deposit_wrapper_utilities.attributes_to_array(
  p_attributes => p_attributes );

push_attributes ( l_attributes );

END push_attributes;

procedure gaz_debug_push_timecard is

CURSOR gaz_blk IS
SELECT *
from hxc_tmp_blks;

CURSOR gaz_att IS
SELECT *
from hxc_tmp_atts;

l_blk gaz_blk%ROWTYPE;
l_att gaz_att%ROWTYPE;

begin



IF ( g_debug ) THEN
	hr_utility.trace('Here are the build blocks....');
END IF;

OPEN  gaz_blk;
FETCH gaz_blk into l_blk;

WHILE gaz_blk%FOUND
LOOP

	IF ( g_debug ) THEN
		hr_utility.trace('bb id   is : '||to_char(l_blk.bb_id));
		hr_utility.trace('measure is : '||to_char(l_blk.measure));
		hr_utility.trace('scope   is : '||l_blk.scope);
        	hr_utility.trace('start time : '||to_char(l_blk.start_time,'hh24:mi:ss dd-mon-yy'));
        	hr_utility.trace('stop  time : '||to_char(l_blk.stop_time,'hh24:mi:ss dd-mon-yy'));
        END IF;

	FETCH gaz_blk INTO l_blk;

END LOOP;

CLOSE gaz_blk;

IF ( g_debug ) THEN
	hr_utility.trace('Here are the attributes ....');
END IF;

OPEN  gaz_att;
FETCH gaz_att into l_att;

WHILE gaz_att%FOUND
LOOP

	IF ( g_debug ) THEN
		hr_utility.trace('ta id   is : '||to_char(l_att.ta_id));
		hr_utility.trace('bb id   is : '||to_char(l_att.bb_id));
		hr_utility.trace('bb info is : '||to_char(l_att.bld_blk_info_type_id));
		hr_utility.trace('att cat is : '||l_att.attribute_category);
		hr_utility.trace('bbit id is : '||to_char(l_att.bld_blk_info_type_id));
		hr_utility.trace('att 1   is : '||l_att.attribute1);
		hr_utility.trace('att 2   is : '||l_att.attribute2);
		hr_utility.trace('att 3   is : '||l_att.attribute3);
		hr_utility.trace('att 4   is : '||l_att.attribute4);
		hr_utility.trace('att 5   is : '||l_att.attribute5);
	END IF;

	FETCH gaz_att INTO l_att;

END LOOP;

CLOSE gaz_att;

end gaz_debug_push_timecard;



-- public procedure
--   push_timecard
--
-- description
--
--   SEE PACKAGE HEADER

PROCEDURE push_timecard ( p_blocks       hxc_block_table_type,
                          p_attributes   hxc_attribute_table_type,
                          p_detail_blocks_only BOOLEAN ) IS


TYPE day_index_tab IS TABLE OF BINARY_INTEGER INDEX BY BINARY_INTEGER;
l_day_index_tab day_index_tab;

l_proc	VARCHAR2(72);

t_bb_id        tab_bb_id;
t_measure      tab_measure;
t_type         tab_type;
t_start_time   tab_start_time;
t_stop_time    tab_stop_time;
t_scope        tab_scope;
t_comment_text tab_comment_text;

l_ind PLS_INTEGER;

x PLS_INTEGER := 0;

l_start_time DATE;
l_stop_time  DATE;

l_trunc_blks VARCHAR2(30) := 'delete from hxc_tmp_blks';
l_trunc_atts VARCHAR2(30) := 'delete from hxc_tmp_atts';

BEGIN

g_debug := hr_utility.debug_enabled;

IF ( g_debug ) THEN
	l_proc := g_package||'push_timecard';
	hr_utility.set_location('Entering '||l_proc, 10);
END IF;

execute immediate l_trunc_blks;
execute immediate l_trunc_atts;

hxc_time_category_utils_pkg.g_tc_bb_not_ok_string := NULL;

-- populate bld blk array

l_ind := p_blocks.FIRST;

WHILE l_ind is not null
loop

IF ( g_debug ) THEN
	hr_utility.trace('scope is '||p_blocks(l_ind).scope);
	hr_utility.trace('start time is '||p_blocks(l_ind).start_time);
	hr_utility.trace('stop time is '||p_blocks(l_ind).stop_time);
END IF;

l_ind := p_blocks.NEXT(l_ind);

end loop;

l_ind := p_blocks.FIRST;

WHILE l_ind IS NOT NULL
LOOP

	-- always set the master timecard id

	IF ( p_blocks(l_ind).scope = 'TIMECARD' )
	THEN
               hxc_time_category_utils_pkg.g_master_tc_info_rec.time_card_id := p_blocks(l_ind).time_building_block_id;
	END IF;

	-- only copy blocks which are NOT deleted

	IF ( FND_DATE.CANONICAL_TO_DATE(p_blocks(l_ind).date_to) = hr_general.end_of_time )
	THEN

		IF ( g_debug ) THEN
			hr_utility.trace('Scope : start time '||p_blocks(l_ind).scope||' : '||p_blocks(l_ind).start_time);
		END IF;

	IF ( NOT p_detail_blocks_only )
	THEN

	        IF ( p_blocks(l_ind).scope = 'DAY' )
	        THEN

	            l_day_index_tab(p_blocks(l_ind).time_building_block_id) := l_ind;

	            l_start_time := FND_DATE.CANONICAL_TO_DATE(p_blocks(l_ind).start_time);
	            l_stop_time  := FND_DATE.CANONICAL_TO_DATE(p_blocks(l_ind).stop_time);

	        ELSIF ( p_blocks(l_ind).scope = 'DETAIL' )
	        THEN

	            IF ( p_blocks(l_ind).type = 'MEASURE' )
	            THEN

	                 IF ( NOT l_day_index_tab.EXISTS(p_blocks(l_ind).parent_building_block_id))
	                 THEN
	                     fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
	                     fnd_message.set_token('PROCEDURE', l_proc);
	                     fnd_message.set_token('STEP','DAY index does not exist ');
	                     fnd_message.raise_error;
	                 END IF;

		            l_start_time :=
            FND_DATE.CANONICAL_TO_DATE(p_blocks(l_day_index_tab(p_blocks(l_ind).parent_building_block_id)).start_time);
		            l_stop_time :=
            FND_DATE.CANONICAL_TO_DATE(p_blocks(l_day_index_tab(p_blocks(l_ind).parent_building_block_id)).stop_time);

	            ELSE

		            l_start_time := FND_DATE.CANONICAL_TO_DATE(p_blocks(l_ind).start_time);
		            l_stop_time  := FND_DATE.CANONICAL_TO_DATE(p_blocks(l_ind).stop_time);

	            END IF; -- ( p_blocks(l_ind).type = 'MEASURE' )

	        ELSE

	            l_start_time := FND_DATE.CANONICAL_TO_DATE(p_blocks(l_ind).start_time);
	            l_stop_time  := FND_DATE.CANONICAL_TO_DATE(p_blocks(l_ind).stop_time);

	        END IF; -- scope test

	ELSE -- all DETAILS with date already denormalised from DAY

            l_start_time := FND_DATE.CANONICAL_TO_DATE(p_blocks(l_ind).start_time);
            l_stop_time  := FND_DATE.CANONICAL_TO_DATE(p_blocks(l_ind).stop_time);

	END IF; -- IF ( NOT p_details_only )

		x := x + 1;

		t_bb_id(x)        := p_blocks(l_ind).time_building_block_id;
		t_measure(x)      := p_blocks(l_ind).measure;
		t_type(x)         := p_blocks(l_ind).type;
		t_start_time(x)   := l_start_time;
		t_stop_time(x)    := l_stop_time;
		t_scope(x)        := p_blocks(l_ind).scope;
		t_comment_text(x) := p_blocks(l_ind).comment_text;

		-- maintain global tc bb not ok string

		IF ( t_scope(x) = 'DETAIL' )
		THEN

			IF ( hxc_time_category_utils_pkg.g_tc_bb_not_ok_string IS NULL )
			THEN

				hxc_time_category_utils_pkg.g_tc_bb_not_ok_string := t_bb_id(x);

			ELSE

				hxc_time_category_utils_pkg.g_tc_bb_not_ok_string
	                             := hxc_time_category_utils_pkg.g_tc_bb_not_ok_string || ', ' || t_bb_id(x);

			END IF;

		END IF; -- t_scope(x) = 'DETAIL'


	END IF; -- IF ( FND_DATE.CANONICAL_TO_DATE(p_blocks(l_ind).date_to) = hr_general.end_of_time )

	l_ind := p_blocks.NEXT(l_ind);

END LOOP;

-- blk insert

FORALL blkx IN 1 .. x

INSERT INTO hxc_tmp_blks (
      bb_id
,     measure
,     type
,     start_time
,     stop_time
,     scope
,     comment_text )
VALUES (
      t_bb_id(blkx)
,     t_measure(blkx)
,     t_type(blkx)
,     t_start_time(blkx)
,     t_stop_time(blkx)
,     t_scope(blkx)
,     t_comment_text(blkx) );

-- delete bld blk array

t_bb_id.delete;
t_measure.delete;
t_type.delete;
t_start_time.delete;
t_stop_time.delete;
t_comment_text.delete;
t_scope.delete;

push_attributes ( p_attributes );


/* **********************************************

   Debug Section

********************************************** */

-- gaz_debug_push_timecard;

IF ( g_debug ) THEN
	hr_utility.set_location('Leaving '||l_proc, 110);
END IF;

END push_timecard;


-- private procedure
--   evaluate_time_sql
--
-- description
--
-- Evaluates the given time category's TIME_SQL against the timecard
-- stored in the temporary table

-- Returns a table of time building blocks which satisfied the TIME_SQL

-- parameters
--   p_time_sql            - Time Category's TIME_SQL
--   p_tc_bb_ok_tab        - Table of Valid bb ids
--   p_tc_bb_ok_string     - string of the valid building blocks
--   p_tc_bb_not_ok_string - string of the building blocks which are still not OK
--   p_operator            - time category operator

PROCEDURE evaluate_time_sql ( p_time_sql                      LONG
                          ,   p_time_sql_clob                 CLOB
                          ,   p_tc_bb_ok_tab        IN OUT NOCOPY t_tc_bb_ok
                          ,   p_tc_bb_ok_string     IN OUT NOCOPY VARCHAR2
                          ,   p_tc_bb_not_ok_string IN OUT NOCOPY VARCHAR2
                          ,   p_operator            IN VARCHAR2 ) IS

l_proc	VARCHAR2(72);


l_select VARCHAR2(75) := '
SELECT DISTINCT ta.bb_id
FROM  hxc_tmp_atts ta
WHERE  ';

l_live_detail VARCHAR2(300) := '
SELECT DISTINCT tau.time_building_block_id bb_id
FROM  hxc_time_attributes ta
,     hxc_time_attribute_usages tau
WHERE tau.time_building_block_id  = :p_tbb_id AND
      tau.time_building_block_ovn = :p_tbb_ovn
AND   ta.time_attribute_id = tau.time_attribute_id
AND  ';

l_live_timecard VARCHAR2(875) := '
SELECT DISTINCT detail.time_building_block_id bb_id
from hxc_time_attributes ta,
     hxc_time_attribute_usages tau,
     hxc_latest_details tbb_latest,
     hxc_time_building_blocks detail,
     hxc_time_building_blocks day
where day.parent_building_block_id  = :p_tbb_id
  and day.parent_building_block_ovn = :p_tbb_ovn
  and detail.parent_building_block_id =
      day.time_building_block_id
  and detail.parent_building_block_ovn =
      day.object_version_number
  and detail.date_to = hr_general.end_of_time
  and tbb_latest.time_building_block_id = detail.time_building_Block_id
  and tbb_latest.object_version_number  = detail.object_version_number
  and tau.time_building_block_id = tbb_latest.time_building_block_id
  and tau.time_building_block_ovn  = tbb_latest.object_Version_number
AND   ta.time_attribute_id = tau.time_attribute_id
AND  ';

l_sql VARCHAR2(32000);

t_bb_id dbms_sql.Number_Table;

l_csr          INTEGER;
l_rows_fetched INTEGER;
l_dummy        INTEGER;

l_bb_ok_string     VARCHAR2(32000);
l_bb_not_ok_string VARCHAR2(32000);

l_time_sql VARCHAR2(32000);

l_parse_time_sql VARCHAR2(32000);


l_between_or  varchar2(32000) := 'not null';
l_before_and varchar2(32000);
l_after_and varchar2(32000);
l_before_equal1 varchar2(32000);
l_before_equal2 varchar2(32000);

-- Bug 8589919
l_index  number :=1000;

BEGIN

IF ( p_time_sql IS NOT NULL )
THEN
	l_time_sql := p_time_sql;
ELSE
	l_time_sql := dbms_lob.substr( p_time_sql_clob, 32000, 1 );
END IF;


IF ( g_debug ) THEN
l_proc := g_package||'evaluate_time_sql';
hr_utility.trace('Params for Evaluate Time SQL are ....');

hr_utility.trace('p_time_sql is : '|| l_time_sql );
hr_utility.trace('p_tc_bb_ok_string is : '||p_tc_bb_ok_string);
hr_utility.trace('p_tc_bb_not_ok_string is : '||p_tc_bb_not_ok_string);
hr_utility.trace('p_operator is : '||p_operator);

hr_utility.set_location('Entering '||l_proc, 10);
END IF;


l_bb_not_ok_string := p_tc_bb_not_ok_string;
l_bb_ok_string     := p_tc_bb_ok_string;

l_parse_time_sql := parse_time_sql_to_bind(l_time_sql);

IF g_debug
THEN

   hr_utility.trace('l_parse_time_sql is ');
   hr_utility.trace( substr(l_parse_time_sql,1,250) );
   hr_utility.trace( substr(l_parse_time_sql,251,250) );
   hr_utility.trace( substr(l_parse_time_sql,501,250) );
   hr_utility.trace( substr(l_parse_time_sql,751,250) );
   hr_utility.trace( substr(l_parse_time_sql,1001,250) );
   hr_utility.trace( substr(l_parse_time_sql,1251,250) );
   hr_utility.trace( substr(l_parse_time_sql,1501,250) );
   hr_utility.trace( substr(l_parse_time_sql,1751,250) );

END IF;

IF ( g_params.p_use_temp_table )
THEN

	IF g_debug
	THEN
	   hr_utility.trace('g_params.p_use_temp_table is TRUE ');
	   hr_utility.trace('p_operator is '||p_operator||' and p_tc_bb_ok_string is '||p_tc_bb_ok_string);
	END IF;

	IF ( ( p_operator = 'AND' ) AND ( p_tc_bb_ok_string IS NOT NULL ) )THEN

          l_sql := l_select || l_parse_time_sql || ' AND ta.bb_id IN ( '||get_token_string (p_tc_bb_ok_string)||' ) ';
	  p_tc_bb_ok_tab.DELETE;
	ELSIF ( p_operator = 'OR' ) AND ( p_tc_bb_not_ok_string IS NOT NULL ) THEN

	  l_sql := l_select || l_parse_time_sql || ' AND ta.bb_id IN ( '||get_token_string (p_tc_bb_not_ok_string)||' ) ';

	ELSIF ( p_operator = 'AND' ) THEN
	  l_sql := l_select || l_parse_time_sql;

	END IF;

ELSIF ( g_params.p_scope = 'DETAIL' )
THEN


	IF g_debug
	THEN
	   hr_utility.trace(' g_params.p_scope is DETAIL ');
	   hr_utility.trace('p_operator is '||p_operator||' and p_tc_bb_ok_string is '||p_tc_bb_ok_string);
	END IF;

	IF ( ( p_operator = 'AND' ) AND ( p_tc_bb_ok_string IS NOT NULL ) )
	THEN
		l_sql := l_live_detail || l_parse_time_sql ||
                         --' AND tau.time_building_block_id IN ( ' || p_tc_bb_ok_string || ' ) ';
                         ' AND tau.time_building_block_id IN ( ' || get_token_string(p_tc_bb_ok_string) || ' ) ';
		p_tc_bb_ok_tab.DELETE;

	ELSIF ( p_operator = 'AND' )
	THEN
		l_sql := l_live_detail || l_parse_time_sql;
	ELSIF ( p_operator = 'OR' )
	THEN
		l_sql := l_live_detail || l_parse_time_sql ||
                         --' AND tau.time_building_block_id IN ( ' || p_tc_bb_not_ok_string || ' ) ';
                         ' AND tau.time_building_block_id IN ( ' || get_token_string(p_tc_bb_not_ok_string) || ' ) ';

	END IF;

ELSIF ( g_params.p_scope = 'TIME' )
THEN

	IF g_debug
	THEN
	   hr_utility.trace(' g_params.p_scope is TIME ');
	   hr_utility.trace('p_operator is '||p_operator||' and p_tc_bb_ok_string is '||p_tc_bb_ok_string);
	END IF;


	-- sum for timecard

	IF ( ( p_operator = 'AND' ) AND ( p_tc_bb_ok_string IS NOT NULL ) )
	THEN

		l_sql := l_live_timecard || l_parse_time_sql ||
                         --' AND tau.time_building_block_id IN ( ' || p_tc_bb_ok_string || ' ) ';
                         ' AND tau.time_building_block_id IN ( ' || get_token_string(p_tc_bb_ok_string) || ' ) ';

		p_tc_bb_ok_tab.DELETE;

	ELSIF ( p_operator = 'AND' )
	THEN
		l_sql := l_live_timecard || l_parse_time_sql;

	ELSIF ( p_operator = 'OR' )
	THEN

		l_sql := l_live_timecard || l_parse_time_sql ||
                         --' AND tau.time_building_block_id IN ( ' || p_tc_bb_not_ok_string || ' ) ';
                         ' AND tau.time_building_block_id IN ( ' || get_token_string(p_tc_bb_not_ok_string) || ' ) ';

	END IF;


END IF; -- p_use_temp_table

IF ( g_debug ) THEN
	hr_utility.trace( 'dynamic time sql is ');
	hr_utility.trace( substr(l_sql,1,250) );
	hr_utility.trace( substr(l_sql,251,250) );
	hr_utility.trace( substr(l_sql,501,250) );
	hr_utility.trace( substr(l_sql,751,250) );
	hr_utility.trace( substr(l_sql,1001,250) );
	hr_utility.trace( substr(l_sql,1251,250) );
	hr_utility.trace( substr(l_sql,1501,250) );
	hr_utility.trace( substr(l_sql,1751,250) );
END IF;

-- for the AND operator need to reset p_tc_bb_ok_string
-- since each AND evaluation should start from scratch

IF ( p_operator = 'AND' )
THEN

	l_bb_ok_string := NULL;

END IF;

-- now fetch rows

l_rows_fetched := 100;

l_csr := dbms_sql.open_cursor;

dbms_sql.parse ( l_csr, l_sql, dbms_sql.native );

IF ( NOT g_params.p_use_temp_table )
THEN

	dbms_sql.bind_variable ( l_csr, ':p_tbb_id' , g_params.p_tbb_id );
	dbms_sql.bind_variable ( l_csr, ':p_tbb_ovn', g_params.p_tbb_ovn );


	IF ( ( p_operator = 'AND' ) AND ( p_tc_bb_ok_string IS NOT NULL ) )
	THEN

	    FOR i IN 1..get_token_count(p_tc_bb_ok_string,',') LOOP
	     dbms_sql.bind_variable_char ( l_csr, ':'||i , get_token(p_tc_bb_ok_string,i,',' ));
	    END LOOP;

	ELSIF ( p_operator = 'OR' )
	THEN

	   FOR i IN 1..get_token_count(p_tc_bb_not_ok_string,',') LOOP
	     dbms_sql.bind_variable_char ( l_csr, ':'||i , get_token(p_tc_bb_not_ok_string,i,',' ));
	   END LOOP;

	END IF;

ELSE

  IF ( ( p_operator = 'AND' ) AND ( p_tc_bb_ok_string IS NOT NULL ) ) THEN

    FOR i IN 1..get_token_count(p_tc_bb_ok_string,',') LOOP

     dbms_sql.bind_variable_char ( l_csr, ':'||i , get_token(p_tc_bb_ok_string,i,',' ));

    END LOOP;

  ELSIF ( p_operator = 'OR' ) AND ( p_tc_bb_not_ok_string IS NOT NULL )  THEN

    FOR i IN 1..get_token_count(p_tc_bb_not_ok_string,',') LOOP
     dbms_sql.bind_variable_char ( l_csr, ':'||i , get_token(p_tc_bb_not_ok_string,i,',' ));
    END LOOP;


  END IF;
  -- replace the parse_time_sql bind

END IF;

-- replace the parse_time_sql bind

WHILE l_between_or is not null
    LOOP
     l_between_or := get_token (l_time_sql,l_index,' OR ');

     IF (l_between_or IS NOT NULL  AND  get_token (l_between_or,3,' AND ') IS NULL) THEN
       -- now I look for the and
       l_before_and := get_token (l_between_or,1,'AND');
       l_after_and  := get_token (l_between_or,2,'AND');

       -- now I can replace the value with the bind
       l_before_equal1 := replace(get_token (l_before_and,2,'='),')','');
       l_before_equal1 := trim(replace(l_before_equal1,'''',''));
       -- Bug 8589919
       dbms_sql.bind_variable( l_csr, ':'||l_index, l_before_equal1 );

       IF (instr(l_after_and,'IS NOT NULL') = 0 AND  instr(l_after_and,'IS NULL') = 0
       		AND  instr(l_after_and,'<>') = 0 AND instr(l_after_and,'IN') = 0) THEN

       -- now I can replace the value with the bind
       l_before_equal2 := replace(get_token (l_after_and,2,'='),')','');
       l_before_equal2 := trim(replace(l_before_equal2,'''',''));

       -- Bug 8589919
       dbms_sql.bind_variable( l_csr, ':'||((l_index)+1),l_before_equal2);

       END IF;

      END IF;
      -- Bug 8589919
      l_index := l_index + 5;

   END LOOP;



dbms_sql.define_array (
	c		=> l_csr
,	position	=> 1
,	n_tab		=> t_bb_id
,	cnt		=> l_rows_fetched
,	lower_bound	=> 1 );

l_dummy	:=	dbms_sql.execute ( l_csr );

-- loop to ensure we fetch all the rows

WHILE ( l_rows_fetched = 100 )
LOOP

	l_rows_fetched	:=	dbms_sql.fetch_rows ( l_csr );

	IF ( g_debug ) THEN
	hr_utility.trace('l rows fetched is '||to_char(l_rows_fetched));
	END IF;

	IF ( l_rows_fetched > 0 )
	THEN

	dbms_sql.column_value (
		c		=> l_csr
	,	position	=> 1
	,	n_tab		=> t_bb_id );

	-- populate p_tc_bb_ok_tab and calc DETAIL hrs

	FOR x IN t_bb_id.FIRST .. t_bb_id.LAST
	LOOP

		p_tc_bb_ok_tab(t_bb_id(x)).bb_id_ok := 'Y';

		IF ( g_debug ) THEN
		hr_utility.trace('bb ok id is '||to_char(t_bb_id(x)));
		END IF;

		-- maintain bb ok string for OR operator

		IF ( x = 1 AND l_bb_ok_string IS NULL )
		THEN
			l_bb_ok_string := to_char(t_bb_id(x));
		ELSE
			l_bb_ok_string := l_bb_ok_string || ', ' || to_char(t_bb_id(x));
		END IF;

		IF ( g_debug ) THEN
		hr_utility.trace('bb ok string is '||l_bb_ok_string);
		hr_utility.trace('bb NOT ok string is '||l_bb_not_ok_string);
		END IF;

		-- maintain bb not ok string i.e. remove the building block from the string

		IF ( SUBSTR( l_bb_not_ok_string, ( INSTR( l_bb_not_ok_string, t_bb_id(x)) + LENGTH(t_bb_id(x))),1)
			= ',' )
		THEN

			-- bb id is followed by a comma

			l_bb_not_ok_string := REPLACE( l_bb_not_ok_string, to_char(t_bb_id(x))||', ');

		ELSIF ( LENGTH( t_bb_id(x) ) < LENGTH( l_bb_not_ok_string ) )
		THEN
			-- bb id not followed by comma and not the last bb id
			-- therefore remove blocks and preceeding comma

			l_bb_not_ok_string := REPLACE( l_bb_not_ok_string, ', '||to_char(t_bb_id(x)));

		ELSE
			-- bb id is the last block in list and the last block therfore
			-- just remove the block - no comma

			l_bb_not_ok_string := REPLACE( l_bb_not_ok_string, to_char(t_bb_id(x)));

		END IF;

		IF ( g_debug ) THEN
		hr_utility.trace('bb NOT ok string AFTER is '||l_bb_not_ok_string);
		END IF;

	END LOOP;

	t_bb_id.DELETE;

	END IF; -- l_rows_fetched > 0

END LOOP;

dbms_sql.close_cursor ( l_csr );

IF ( g_debug ) THEN
hr_utility.trace('GAZ - BB OK string is     '||l_bb_ok_string);
hr_utility.trace('GAZ - BB NOT OK string is '||l_bb_not_ok_string);
END IF;

p_tc_bb_ok_string     := l_bb_ok_string;
p_tc_bb_not_ok_string := l_bb_not_ok_string;

IF ( g_debug ) THEN
hr_utility.set_location('Leaving '||l_proc, 170);
END IF;

exception when others then

	IF ( g_debug ) THEN
	hr_utility.trace('in exception');
	END IF;

	raise;

END evaluate_time_sql;


-- private procedure
--   value_set_string
--
-- Description
--
-- Creates the dynamic sql string associated with the TCC

-- parameters
--   p_rec             - Time Category Component record
--   p_vs_sql          - dynamic sql string


PROCEDURE value_set_string ( p_rec     hxc_tcc_shd.g_rec_type
                           , p_vs_sql  IN OUT NOCOPY LONG ) IS

CURSOR csr_get_mpc_info ( p_mapping_component_id NUMBER ) IS
SELECT
	bbit.bld_blk_info_type context
,	bbit.bld_blk_info_type_id
,	mpc.segment
FROM
        hxc_bld_blk_info_types bbit
,       hxc_mapping_components mpc
WHERE
	mpc.mapping_component_id = p_mapping_component_id
AND
        bbit.bld_blk_info_type_id = mpc.bld_blk_info_type_id;


l_comps_r csr_get_category_comps%ROWTYPE;

l_mpc_r   csr_get_mpc_info%ROWTYPE;

l_sql    LONG;
l_vs_sql LONG;

r_valueset	fnd_vset.valueset_r;
r_format 	fnd_vset.valueset_dr;

l_where_clause   VARCHAR2(32000);
l_sql_ok BOOLEAN;

l_order_by_start NUMBER;


BEGIN -- value_set_string



l_first_time_round := TRUE;

IF ( p_rec.type <> 'MC_VS' )
THEN
	fnd_message.set_name ('HXC','HXC_GAZ_NOT_A_VS_ROW');
	fnd_message.raise_error;
END IF;

-- first check the SQL associated with the value set has
-- no $FLEX$ OR $PROFILE$

chk_profile_flex( p_rec.flex_value_set_id
                , l_where_clause
                , l_sql_ok);

IF ( NOT l_sql_ok )
THEN
  fnd_message.set_name('HXC', 'HXC_TCC_CANNOT_USE_MPC');
  fnd_message.raise_error;
END IF;

-- get the time category operator

OPEN  csr_get_operator ( p_rec.time_category_id );
FETCH csr_get_operator INTO l_operator;
CLOSE csr_get_operator;

-- get the mapping component information

OPEN  csr_get_mpc_info ( p_rec.component_type_id );
FETCH csr_get_mpc_info INTO l_mpc_r;
CLOSE csr_get_mpc_info;


l_comps_r.context                   := l_mpc_r.context;
l_comps_r.bld_blk_info_type_id      := l_mpc_r.bld_blk_info_type_id;
l_comps_r.segment                   := l_mpc_r.segment;
l_comps_r.value_id                  := '<VALUE_SET_SQL>';
l_comps_r.ref_time_category_id      := -1; -- dummy value not used
l_comps_r.flex_value_set_id         := p_rec.flex_value_set_id;
l_comps_r.equal_to                  := p_rec.equal_to;

	get_dyn_sql ( p_time_sql => l_sql
		    , p_comps_r  => l_comps_r
                    , p_operator => l_operator
                    , p_vs_sql   => TRUE );

-- Now get the value set sql

fnd_vset.GET_VALUESET (
 VALUESET_ID          => l_comps_r.flex_value_set_id
,VALUESET             => r_valueset
,FORMAT               => r_format );

IF ( g_debug ) THEN
	hr_utility.trace('where is '||r_valueset.table_info.where_clause);
END IF;



l_order_by_start := INSTR( UPPER ( r_valueset.table_info.where_clause ), 'ORDER' );

IF ( l_order_by_start <> 0 )
THEN

	l_where_clause := SUBSTR( r_valueset.table_info.where_clause, 1, (l_order_by_start-1));

ELSE

	l_where_clause := r_valueset.table_info.where_clause;

END IF;

IF ( ( INSTR ( UPPER( l_where_clause ), 'WHERE'  ) = 0 )
   AND
     ( LENGTH ( l_where_clause ) <> 0 ) )
THEN
	-- no where

	l_where_clause := ' WHERE '||l_where_clause;

END IF;

	l_vs_sql := ' SELECT ' || r_valueset.table_info.id_column_name || ' FROM ' ||
                          r_valueset.table_info.table_name || ' ' ||
                          l_where_clause || ' ) ';

IF ( g_debug ) THEN
	hr_utility.trace('Value Set SQL is ');

	hr_utility.trace( substr(l_vs_sql,1,250) );
	hr_utility.trace( substr(l_vs_sql,251,250) );
	hr_utility.trace( substr(l_vs_sql,501,250) );
	hr_utility.trace( substr(l_vs_sql,751,250) );
	hr_utility.trace( substr(l_vs_sql,1001,250) );
	hr_utility.trace( substr(l_vs_sql,1251,250) );
	hr_utility.trace( substr(l_vs_sql,1501,250) );
	hr_utility.trace( substr(l_vs_sql,1751,250) );
END IF;

l_vs_sql := REPLACE ( l_sql, '<VALUE_SET_SQL>', l_vs_sql );

	IF ( g_debug ) THEN
		hr_utility.trace('Final Value Set String ...');
		hr_utility.trace( substr(l_vs_sql,1,250) );
		hr_utility.trace( substr(l_vs_sql,251,250) );
		hr_utility.trace( substr(l_vs_sql,501,250) );
		hr_utility.trace( substr(l_vs_sql,751,250) );
		hr_utility.trace( substr(l_vs_sql,1001,250) );
		hr_utility.trace( substr(l_vs_sql,1251,250) );
		hr_utility.trace( substr(l_vs_sql,1501,250) );
		hr_utility.trace( substr(l_vs_sql,1751,250) );
	END IF;

p_vs_sql := l_vs_sql;


END value_set_string;





PROCEDURE sum_tc_bb_ok_hrs ( p_tc_bb_ok_string   VARCHAR2
                           , p_hrs IN OUT NOCOPY NUMBER
                           , p_period_start      DATE
                           , p_period_end        DATE  ) IS

l_proc	VARCHAR2(72);

l_select VARCHAR2(300) := '
SELECT SUM( DECODE( tbb.type, ''RANGE'',
       (((tbb.stop_time)-(tbb.start_time))*24),
        NVL(tbb.measure, 0) )) hrs
FROM   hxc_tmp_blks tbb
WHERE  tbb.scope = ''DETAIL'' AND
       tbb.start_time  <  :p_period_end AND
        tbb.start_time >=  :p_period_start AND
       tbb.bb_id IN ( ';

l_select_null  VARCHAR2(275) := '
SELECT SUM( DECODE( tbb.type, ''RANGE'',
       (((tbb.stop_time)-(tbb.start_time))*24),
        NVL(tbb.measure, 0) )) hrs
FROM   hxc_tmp_blks tbb
WHERE  tbb.scope = ''DETAIL'' AND
       tbb.start_time  <  :p_period_end AND
        tbb.start_time >=  :p_period_start ';

l_csr INTEGER;

l_sql VARCHAR2(32000);

l_hrs NUMBER := 0;

l_rows_processed NUMBER := 0;

BEGIN

g_debug := hr_utility.debug_enabled;

IF ( g_debug ) THEN
	l_proc := g_package||'sum_bb_ok_hrs';
	hr_utility.trace('Params are ');
	hr_utility.trace('p_tc_bb_ok_string is '||p_tc_bb_ok_string);
	hr_utility.trace('p_hrs are '||to_char(p_hrs));
	hr_utility.trace('p_period_start is '||to_char(p_period_start,'hh24:mi:ss DD-MON-YY'));
	hr_utility.trace('p_period_end is   '||to_char(p_period_end,'HH24:MI:SS DD-MON-YY'));


	hr_utility.set_location('Entering '||l_proc, 10);
END IF;

IF ( p_tc_bb_ok_string IS NOT NULL )
THEN
	--l_sql := l_select || p_tc_bb_ok_string || ' ) ';
	l_sql := l_select || get_token_string(p_tc_bb_ok_string) || ' ) ';

	IF ( g_debug ) THEN
		hr_utility.trace( 'dynamic hrs sql is ');
		hr_utility.trace( substr(l_sql,1,250) );
		hr_utility.trace( substr(l_sql,251,250) );
		hr_utility.trace( substr(l_sql,501,250) );
		hr_utility.trace( substr(l_sql,751,250) );
		hr_utility.trace( substr(l_sql,1001,250) );
		hr_utility.trace( substr(l_sql,1251,250) );
		hr_utility.trace( substr(l_sql,1501,250) );
		hr_utility.trace( substr(l_sql,1751,250) );
	END IF;

	l_csr := dbms_sql.open_cursor;

	dbms_sql.parse ( l_csr, l_sql, dbms_sql.native );

	FOR i IN 1..get_token_count(p_tc_bb_ok_string,',') LOOP

	     dbms_sql.bind_variable_char ( l_csr, ':'||i , get_token(p_tc_bb_ok_string,i,',' ));

	END LOOP;

	dbms_sql.bind_variable ( l_csr, ':p_period_end' , p_period_end );
	dbms_sql.bind_variable ( l_csr, ':p_period_start', p_period_start);

	 DBMS_SQL.DEFINE_COLUMN (l_csr, 1, l_hrs);
	--execute immediate l_sql INTO l_hrs USING p_period_end, p_period_start;
	l_rows_processed := dbms_sql.execute ( l_csr );

	IF DBMS_SQL.FETCH_ROWS (l_csr) > 0 THEN
		DBMS_SQL.COLUMN_VALUE (l_csr, 1, l_hrs);
	END IF;

	dbms_sql.close_cursor ( l_csr );

ELSIF ( hxc_time_category_utils_pkg.g_time_category_id IS NULL )
THEN

	l_sql := l_select_null;

	execute immediate l_sql INTO l_hrs USING p_period_end, p_period_start;

ELSE

	l_hrs := 0;


END IF; -- IF ( p_tc_bb_ok_string IS NOT NULL )

IF ( g_debug ) THEN
	hr_utility.trace('GAZ - HOURS ARE : '||to_char(NVL(l_hrs,0)));
END IF;

p_hrs := NVL(l_hrs,0);

IF ( g_debug ) THEN
	hr_utility.set_location('Leaving '||l_proc, 170);
END IF;

END sum_tc_bb_ok_hrs;



PROCEDURE sum_live_tc_bb_ok_hrs ( p_tc_bb_ok_string   VARCHAR2
                                , p_hrs IN OUT NOCOPY NUMBER ) IS

l_proc	VARCHAR2(72);

l_select VARCHAR2(450) := '
SELECT SUM( DECODE( tbb.type, ''RANGE'',
       (((tbb.stop_time)-(tbb.start_time))*24),
        NVL(tbb.measure, 0) )) hrs
FROM   hxc_time_building_blocks tbb
,      hxc_latest_details hld
WHERE  tbb.time_building_block_id = hld.time_building_block_id
AND    tbb.object_version_number  = hld.object_version_number
AND    hld.time_building_block_id IN ( ';

l_csr INTEGER;

l_sql VARCHAR2(32000);

l_hrs NUMBER := 0;

l_rows_processed NUMBER := 0;

BEGIN


IF ( p_tc_bb_ok_string IS NOT NULL )
THEN

	--l_sql := l_select || p_tc_bb_ok_string || ' ) ';

	l_sql := l_select || get_token_string(p_tc_bb_ok_string) || ' ) ';

	IF ( g_debug ) THEN
		l_proc := g_package||'sum_live_tc_bb_ok_hrs';
		hr_utility.trace( 'dynamic hrs sql is ');
		hr_utility.trace( substr(l_sql,1,250) );
		hr_utility.trace( substr(l_sql,251,250) );
		hr_utility.trace( substr(l_sql,501,250) );
		hr_utility.trace( substr(l_sql,751,250) );
		hr_utility.trace( substr(l_sql,1001,250) );
		hr_utility.trace( substr(l_sql,1251,250) );
		hr_utility.trace( substr(l_sql,1501,250) );
		hr_utility.trace( substr(l_sql,1751,250) );
	END IF;

	l_csr := dbms_sql.open_cursor;

	dbms_sql.parse ( l_csr, l_sql, dbms_sql.native );

	FOR i IN 1..get_token_count(p_tc_bb_ok_string,',') LOOP

	     dbms_sql.bind_variable_char ( l_csr, ':'||i , get_token(p_tc_bb_ok_string,i,',' ));

	END LOOP;

	DBMS_SQL.DEFINE_COLUMN (l_csr, 1, l_hrs);
	--execute immediate l_sql INTO l_hrs;
	l_rows_processed := dbms_sql.execute ( l_csr );

	IF DBMS_SQL.FETCH_ROWS (l_csr) > 0 THEN
		DBMS_SQL.COLUMN_VALUE (l_csr, 1, l_hrs);
	END IF;

	dbms_sql.close_cursor ( l_csr );


ELSE

	l_hrs := 0;

END IF; -- IF ( p_tc_bb_ok_string IS NOT NULL )

IF ( g_debug ) THEN
	hr_utility.trace('GAZ - HOURS ARE : '||to_char(NVL(l_hrs,0)));
END IF;

p_hrs := NVL( l_hrs, 0 );

IF ( g_debug ) THEN
	hr_utility.set_location('Leaving '||l_proc, 170);
END IF;

END sum_live_tc_bb_ok_hrs;





--Same as above
--But we need to process each detail block
--according to precision and rounding rule


PROCEDURE sum_live_tc_bb_ok_hrs ( p_tc_bb_ok_string  IN VARCHAR2
                                , p_hrs IN OUT NOCOPY NUMBER
				, p_rounding_rule IN VARCHAR2
				, p_decimal_precision IN VARCHAR2) IS

l_proc	VARCHAR2(72);

l_select VARCHAR2(700) := 'SELECT SUM( HXC_FIND_NOTIFY_APRS_PKG.apply_round_rule('||''''||
                      p_rounding_rule||''''||','||''''||
                      p_decimal_precision||''''||',
		      (DECODE( tbb.type, ''RANGE'',
                       (((tbb.stop_time)-(tbb.start_time))*24),
                       NVL(tbb.measure, 0) ))
                       )) hrs
FROM   hxc_time_building_blocks tbb
,      hxc_latest_details hld
WHERE  tbb.time_building_block_id = hld.time_building_block_id
AND    tbb.object_version_number  = hld.object_version_number
AND    hld.time_building_block_id IN ( ';

l_sql VARCHAR2(32000);

l_hrs NUMBER := 0;

BEGIN


IF ( p_tc_bb_ok_string IS NOT NULL )
THEN

	l_sql := l_select || p_tc_bb_ok_string || ' ) ';

	IF ( g_debug ) THEN
		l_proc := g_package||'sum_live_tc_bb_ok_hrs';
		hr_utility.trace( 'dynamic hrs sql is ');
		hr_utility.trace( substr(l_sql,1,250) );
		hr_utility.trace( substr(l_sql,251,250) );
		hr_utility.trace( substr(l_sql,501,250) );
		hr_utility.trace( substr(l_sql,751,250) );
		hr_utility.trace( substr(l_sql,1001,250) );
		hr_utility.trace( substr(l_sql,1251,250) );
		hr_utility.trace( substr(l_sql,1501,250) );
		hr_utility.trace( substr(l_sql,1751,250) );
	END IF;

	execute immediate l_sql INTO l_hrs;

ELSE

	l_hrs := 0;

END IF; -- IF ( p_tc_bb_ok_string IS NOT NULL )

IF ( g_debug ) THEN
	hr_utility.trace('GAZ - HOURS ARE : '||to_char(NVL(l_hrs,0)));
END IF;

p_hrs := NVL( l_hrs, 0 );

IF ( g_debug ) THEN
	hr_utility.set_location('Leaving '||l_proc, 170);
END IF;

END sum_live_tc_bb_ok_hrs;





-- public procedure
--   evaluate_time_category
--
-- description
--
-- SEE HEADER
--

PROCEDURE evaluate_time_category ( p_time_category_id     IN NUMBER
                               ,   p_tc_bb_ok_tab         IN OUT NOCOPY t_tc_bb_ok
                               ,   p_tc_bb_ok_string      IN OUT NOCOPY VARCHAR2
                               ,   p_tc_bb_not_ok_string  IN OUT NOCOPY VARCHAR2
                               ,   p_use_tc_cache         IN BOOLEAN  DEFAULT TRUE
                               ,   p_use_tc_bb_cache      IN BOOLEAN  DEFAULT TRUE
                               ,   p_use_temp_table       IN BOOLEAN  DEFAULT TRUE
                               ,   p_scope                IN VARCHAR2 DEFAULT 'TIME'
                               ,   p_tbb_id               IN NUMBER   DEFAULT NULL
                               ,   p_tbb_ovn              IN NUMBER   DEFAULT NULL ) IS

l_proc	VARCHAR2(72);

CURSOR	csr_get_category_comps ( p_time_category_id NUMBER ) IS
SELECT
        tcc.time_category_id
,       tcc.time_category_comp_id
,	tcc.type
,	bbit.bld_blk_info_type_id
,	mpc.segment
,       tcc.component_type_id
,	tcc.ref_time_category_id
,	tcc.flex_value_set_id
,       tcc.value_id
,       tcc.is_null
,       tcc.equal_to
,       tccs.sql_string
,       tcc.last_update_date
FROM
	hxc_time_category_comp_sql tccs
,       hxc_bld_blk_info_types bbit
,       hxc_mapping_components mpc
,       hxc_time_category_comps tcc
WHERE	tcc.time_category_id = p_time_category_id AND
        tcc.type <> 'MC'
AND
        mpc.mapping_component_id (+) = tcc.component_type_id
AND
        bbit.bld_blk_info_type_id (+) = mpc.bld_blk_info_type_id
AND
        tccs.time_category_comp_id (+) = tcc.time_category_comp_id;

CURSOR csr_get_tbbs IS
SELECT bb_id,
       scope
FROM   hxc_tmp_blks;


CURSOR csr_get_live_tbbs ( p_bb_id NUMBER, p_bb_ovn NUMBER ) IS
SELECT detail.time_building_block_id bb_id,
       detail.scope
FROM hxc_latest_details tbb_latest,
     hxc_time_building_blocks detail,
     hxc_time_building_blocks day
where day.parent_building_block_id  = p_bb_id
  and day.parent_building_block_ovn = p_bb_ovn
  and detail.parent_building_block_id =
      day.time_building_block_id
  and detail.parent_building_block_ovn =
      day.object_version_number
  and tbb_latest.time_building_block_id = detail.time_building_Block_id
  and tbb_latest.object_version_number  = detail.object_version_number
  and detail.date_to = hr_general.end_of_time;


-- local variable defintions

l_time_category_info  csr_get_time_category%ROWTYPE;
l_time_category_comps csr_get_category_comps%ROWTYPE;

l_empty_time_category BOOLEAN := FALSE;

l_tc_bb_not_ok_string VARCHAR2(32000);

l_vs_comp_tab t_vs_comp;
l_vs_ind      PLS_INTEGER := 1;

l_an_comp_tab t_an_comp;
l_an_ind      PLS_INTEGER := 1;

l_tc_comp_tab t_tc_comp;
l_tc_ind      PLS_INTEGER := 1;


BEGIN -- evaluate_time_category
g_debug := hr_utility.debug_enabled;

g_params.p_time_category_id := p_time_category_id;
g_params.p_use_tc_cache     := p_use_tc_cache;
g_params.p_use_tc_bb_cache  := p_use_tc_bb_cache;
g_params.p_use_temp_table   := p_use_temp_table;
g_params.p_scope            := p_scope;
g_params.p_tbb_id           := p_tbb_id;
g_params.p_tbb_ovn          := p_tbb_ovn;

-- gaz_debug_push_timecard;

IF ( g_debug ) THEN
l_proc := g_package||'evaluate_time_category';
hr_utility.trace('*****************************************************');
hr_utility.trace('Params are :');
hr_utility.trace('tc id is   : '||TO_CHAR(g_params.p_time_category_id));
hr_utility.trace('scope is   : '||g_params.p_scope);
hr_utility.trace('tbb id is  : '||TO_CHAR(g_params.p_tbb_id));
hr_utility.trace('tbb ovn is : '||TO_CHAR(g_params.p_tbb_ovn));
hr_utility.trace('Master tc id '||to_char(hxc_time_category_utils_pkg.g_master_tc_info_rec.time_category_id));
hr_utility.trace('Master TC id '||to_char(hxc_time_category_utils_pkg.g_master_tc_info_rec.time_card_id));
hr_utility.trace('Master att cnt '||to_char(hxc_time_category_utils_pkg.g_master_tc_info_rec.attribute_count));

IF ( g_params.p_use_tc_cache )
THEN
	hr_utility.trace('p_use_tc_cache is TRUE');
ELSE
	hr_utility.trace('p_use_tc_cache is FALSE');
END IF;

IF ( g_params.p_use_tc_bb_cache )
THEN
	hr_utility.trace('p_use_tc_bb_cache is TRUE');
ELSE
	hr_utility.trace('p_use_tc_bb_cache is FALSE');
END IF;
IF ( g_params.p_use_temp_table )
THEN
	hr_utility.trace('p_use_temp_table is TRUE');
ELSE
	hr_utility.trace('p_use_temp_table is FALSE');
END IF;

hr_utility.trace('tc bb ok string '||p_tc_bb_ok_string);

END IF; -- l debug


-- check time category cache

IF ( p_use_tc_cache AND tc_cache_exists ( p_time_category_id ) )
THEN

	IF ( g_debug ) THEN
	hr_utility.trace('Using time category cache');
	END IF;

	l_tc_cache_exists    := TRUE;

	l_time_category_info.operator := g_tc_cache(p_time_category_id).operator;
	l_time_category_info.time_sql := g_tc_cache(p_time_category_id).time_sql;

ELSE

	IF ( g_debug ) THEN
	hr_utility.trace('NOT using time category cache');
	END IF;

	-- get time category TIME_SQL and OPERATOR

	OPEN  csr_get_time_category ( p_time_category_id);
	FETCH csr_get_time_category INTO l_time_category_info;

	IF csr_get_time_category%NOTFOUND
	THEN
		-- empty time category

		IF ( g_debug ) THEN
		hr_utility.trace('Time Category EMPTY anyway !!!');
		END IF;

		l_empty_time_category := TRUE;
		/* bug fix for 5076837 */
		  g_empty_time_category_tab(p_time_category_id).p_status:=TRUE;
		/* end of fix for bug 5078637 */
	END IF;

	CLOSE csr_get_time_category;

	l_tc_cache_exists    := FALSE;

	-- must be false since TC not in cache

	l_tc_bb_cache_exists := FALSE;

END IF; -- using cache


-- DO NOTHING IF THE TIME CATEGORY IS EMPTY


IF ( NOT l_empty_time_category )
THEN


-- For the master time category check the cache

IF ( hxc_time_category_utils_pkg.g_master_tc_info_rec.time_category_id IS NULL )
THEN

	IF ( g_debug ) THEN
	hr_utility.trace('Master Time Category !!!!!!');
	END IF;

	-- set master TC info

	hxc_time_category_utils_pkg.g_time_category_id := p_time_category_id;

	hxc_time_category_utils_pkg.g_master_tc_info_rec.time_category_id := p_time_category_id;
	hxc_time_category_utils_pkg.g_master_tc_info_rec.operator         := l_time_category_info.operator;



	-- check tc bb cache

	IF ( g_tc_bb_ok_cache.exists( p_time_category_id ) AND p_use_tc_bb_cache )
	THEN

		IF ( g_debug ) THEN
		hr_utility.trace('tc bb ok cache exists');
		END IF;

		IF ( ( g_tc_bb_ok_cache(p_time_category_id).timecard_id =
                       hxc_time_category_utils_pkg.g_master_tc_info_rec.time_card_id ) AND
                     ( g_tc_bb_ok_cache(p_time_category_id).attribute_count =
                       hxc_time_category_utils_pkg.g_master_tc_info_rec.attribute_count ) )
		THEN

			IF ( g_debug ) THEN
			hr_utility.trace('Using tc bb ok cache');
			END IF;

			l_tc_bb_cache_exists := TRUE;

		ELSE
			-- different timecard therefore cannot use cache

			IF ( g_debug ) THEN
			hr_utility.trace('NOT using tc bb ok cache - diff TC ID');
			END IF;

			l_tc_bb_cache_exists := FALSE;
			g_tc_bb_ok_cache(p_time_category_id).bb_ok_string := NULL;

		END IF;

	ELSE

		IF ( g_debug ) THEN
		hr_utility.trace('tc bb ok cache NOT EXISTS');
		END IF;

		l_tc_bb_cache_exists := FALSE;

	END IF;




	IF ( NOT l_tc_bb_cache_exists OR NOT p_use_tc_bb_cache )
	THEN

	-- if the TC building block cache does not exist or we are
        -- not supposed to use it then generate the not ok string
	-- for time category evaluation since we are going to evaluate
	-- the time category from scratch

	IF ( p_use_temp_table )
	THEN
		IF ( g_debug ) THEN
		hr_utility.trace('Using temporary table to generate not ok bbs');
		END IF;

		IF ( hxc_time_category_utils_pkg.g_tc_bb_not_ok_string IS NULL )
		THEN

		-- generate tc_bb_not_ok_string (this should always be generated in
		-- push_timecard)

		FOR tmp_bb_rec IN csr_get_tbbs
		LOOP

			IF ( tmp_bb_rec.scope = 'DETAIL' )
			THEN

				IF ( p_tc_bb_not_ok_string IS NULL )
				THEN

					p_tc_bb_not_ok_string := tmp_bb_rec.bb_id;

				ELSE

					p_tc_bb_not_ok_string := p_tc_bb_not_ok_string || ', ' || tmp_bb_rec.bb_id;

				END IF;

			END IF;

		END LOOP;

		IF ( g_debug ) THEN
		hr_utility.trace('bb not ok string is '||p_tc_bb_not_ok_string);
		END IF;

		ELSE -- hxc_time_category_utils_pkg.g_tc_bb_not_ok_string IS NOT NULL

			p_tc_bb_not_ok_string := hxc_time_category_utils_pkg.g_tc_bb_not_ok_string;

			IF ( g_debug ) THEN
			hr_utility.trace('Using cache : bb not ok string is '||p_tc_bb_not_ok_string);
			END IF;

		END IF; -- hxc_time_category_utils_pkg.g_tc_bb_not_ok_string IS NULL

	ELSE -- using live table

		IF ( g_debug ) THEN
		hr_utility.trace('Using the live table');
		END IF;

		IF ( p_scope = 'TIME' )
		THEN

			IF ( g_debug ) THEN
			hr_utility.trace('Scope is TIME');
			END IF;

			-- populate p tc bb not ok string from timecard

			FOR tmp_bb_rec IN csr_get_live_tbbs ( g_params.p_tbb_id, g_params.p_tbb_ovn )
			LOOP
				IF ( tmp_bb_rec.scope = 'DETAIL' )
				THEN

					IF ( p_tc_bb_not_ok_string IS NULL )
					THEN
						p_tc_bb_not_ok_string := tmp_bb_rec.bb_id;
					ELSE

					     p_tc_bb_not_ok_string := p_tc_bb_not_ok_string || ', ' || tmp_bb_rec.bb_id;

					END IF;

					IF ( g_debug ) THEN
					hr_utility.trace('bb not ok string is '||p_tc_bb_not_ok_string);
					END IF;

				END IF;

			END LOOP;

		ELSIF ( p_scope = 'DAY' )
		THEN
			-- not supported

                        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
                        fnd_message.set_token('PROCEDURE', l_proc);
                        fnd_message.set_token('STEP','DAY not supported!');
                        fnd_message.raise_error;

		ELSIF ( p_scope = 'DETAIL' )
		THEN

			IF ( g_debug ) THEN
			hr_utility.trace('Scope is DETAIL');
			END IF;

			p_tc_bb_not_ok_string := g_params.p_tbb_id;

			IF ( g_debug ) THEN
			hr_utility.trace('bb not ok string is '||p_tc_bb_not_ok_string);
			END IF;

		END IF;

	END IF; -- p_use_temp_table

	p_tc_bb_not_ok_string := NVL( p_tc_bb_not_ok_string, '-99999999' );

	END IF; -- IF ( NOT l_tc_bb_cache_exists OR NOT p_use_tc_bb_cache )

ELSE -- not master time category

	-- can only use bb cache for master time category

	l_tc_bb_cache_exists := FALSE;

END IF; -- IF ( hxc_time_category_utils_pkg.g_master_tc_info_rec.time_category_id IS NULL )




IF (  NOT l_tc_bb_cache_exists OR NOT p_use_tc_bb_cache )
THEN

	IF ( g_debug ) THEN
	hr_utility.trace('NOT using tc bb cache');
	END IF;

-- get time category components

IF ( l_tc_cache_exists )
THEN

	-- populate TC component tables from cache

	l_vs_comp_tab.DELETE;
	l_an_comp_tab.DELETE;
	l_tc_comp_tab.DELETE;

	get_tc_from_cache ( p_time_category_id => p_time_category_id
                          , p_vs_comp_tab      => l_vs_comp_tab
                          , p_an_comp_tab      => l_an_comp_tab
                          , p_tc_comp_tab      => l_tc_comp_tab );

ELSE

IF ( g_debug ) THEN
hr_utility.trace('about to get tc comps');
END IF;

OPEN  csr_get_category_comps( p_time_category_id );
FETCH csr_get_category_comps INTO l_time_category_comps;

WHILE csr_get_category_comps%FOUND
LOOP

	IF ( l_time_category_comps.type = 'MC_VS' )
	THEN

		l_vs_comp_tab(l_vs_ind).time_category_id      := l_time_category_comps.time_category_id;
		l_vs_comp_tab(l_vs_ind).time_category_comp_id := l_time_category_comps.time_category_comp_id;
		l_vs_comp_tab(l_vs_ind).component_type_id     := l_time_category_comps.component_type_id;
		l_vs_comp_tab(l_vs_ind).flex_value_set_id     := l_time_category_comps.flex_value_set_id;
		l_vs_comp_tab(l_vs_ind).sql_string            := l_time_category_comps.sql_string;
		l_vs_comp_tab(l_vs_ind).is_null               := l_time_category_comps.is_null;
		l_vs_comp_tab(l_vs_ind).equal_to              := l_time_category_comps.equal_to;
		l_vs_comp_tab(l_vs_ind).last_update_date      := l_time_category_comps.last_update_date;

		l_vs_ind := l_vs_ind + 1;

	ELSIF ( l_time_category_comps.type = 'AN' )
	THEN
		-- maintain alternate name table

		l_an_comp_tab(l_an_ind).sql_string := l_time_category_comps.sql_string;

		l_an_ind := l_an_ind + 1;

	ELSIF ( l_time_category_comps.type = 'BB' )
	THEN
		-- maintain building block table

		null;

	ELSIF ( l_time_category_comps.type = 'TC' )
	THEN
		-- maintain ref time category table

		l_tc_comp_tab(l_tc_ind).ref_tc_id := l_time_category_comps.ref_time_category_id;

		l_tc_ind := l_tc_ind + 1;

	ELSIF ( l_time_category_comps.type = 'FF' )
	THEN
		-- maintain fast formula table

		null;

	END IF;

	FETCH csr_get_category_comps INTO l_time_category_comps;

END LOOP;

IF ( g_debug ) THEN
hr_utility.trace('Category Component Table Counts are .......');
hr_utility.trace('MC_VS count is '||to_char(l_vs_comp_tab.count));
hr_utility.trace('AN    count is '||to_char(l_an_comp_tab.count));
hr_utility.trace('TC    count is '||to_char(l_tc_comp_tab.count));
END IF;

	-- maintain TC CACHE

	add_tc_to_cache ( p_time_category_id   => p_time_category_id
                        , p_time_category_info => l_time_category_info
                        , p_vs_comp_tab        => l_vs_comp_tab
                        , p_an_comp_tab        => l_an_comp_tab
                        , p_tc_comp_tab        => l_tc_comp_tab );

END IF; -- IF ( l_tc_cache_exists )


l_continue_evaluation := TRUE;

-- ***************************************************
-- now evaluate the different time category components
-- easiest components first i.e.
-- BB, MC, MC_VS, AN, FF, TC
-- ***************************************************

-- ******************** Mapping Component Components ********************

IF ( l_time_category_info.time_sql IS NOT NULL AND l_continue_evaluation )
THEN

	-- TYPE = MC

	IF ( g_debug ) THEN
	hr_utility.trace('Evaluating MC');
	END IF;

	evaluate_time_sql ( l_time_category_info.time_sql
                          , NULL
                          , p_tc_bb_ok_tab
                          , p_tc_bb_ok_string
                          , p_tc_bb_not_ok_string
                          , hxc_time_category_utils_pkg.g_master_tc_info_rec.operator );

	l_continue_evaluation := continue_evaluation ( hxc_time_category_utils_pkg.g_master_tc_info_rec.operator
                                             , p_tc_bb_ok_string
                                             , p_tc_bb_not_ok_string );


END IF;


-- *********** Mapping Component with Value Set Components ************

IF ( l_vs_comp_tab.COUNT <> 0 AND l_continue_evaluation )
THEN

	-- TYPE = MC_VS

	l_vs_ind := l_vs_comp_tab.FIRST;

	WHILE ( l_vs_ind IS NOT NULL AND l_continue_evaluation )
	LOOP
		-- check that the value set definition has not
		-- changed since the tc comp row was updated
		-- if so - then call value_set_string and
		-- maintain tccs again

		IF ( g_debug ) THEN
		hr_utility.trace('Evaluating MC_VS Loop');
		END IF;

		evaluate_time_sql ( NULL
                          , l_vs_comp_tab(l_vs_ind).sql_string
                          , p_tc_bb_ok_tab
                          , p_tc_bb_ok_string
                          , p_tc_bb_not_ok_string
                          , hxc_time_category_utils_pkg.g_master_tc_info_rec.operator );

		l_vs_ind := l_vs_comp_tab.NEXT(l_vs_ind);

		l_continue_evaluation := continue_evaluation ( hxc_time_category_utils_pkg.g_master_tc_info_rec.operator
                                                             , p_tc_bb_ok_string
                                                             , p_tc_bb_not_ok_string );

	END LOOP;

END IF; -- l_vs_comp_tab.COUNT <> 0


-- ******************** Alternate Name Components *****************************

IF ( l_an_comp_tab.COUNT <> 0 AND l_continue_evaluation )
THEN

	-- TYPE = AN

	l_an_ind := l_an_comp_tab.FIRST;

	WHILE ( l_an_ind IS NOT NULL AND l_continue_evaluation )
	LOOP

		IF ( g_debug ) THEN
		hr_utility.trace('Evaluating AN Loop');
		END IF;

		evaluate_time_sql ( NULL
                          , l_an_comp_tab(l_an_ind).sql_string
                          , p_tc_bb_ok_tab
                          , p_tc_bb_ok_string
                          , p_tc_bb_not_ok_string
                          , hxc_time_category_utils_pkg.g_master_tc_info_rec.operator );

		l_an_ind := l_an_comp_tab.NEXT(l_an_ind);

		l_continue_evaluation := continue_evaluation ( hxc_time_category_utils_pkg.g_master_tc_info_rec.operator
                                                             , p_tc_bb_ok_string
                                                             , p_tc_bb_not_ok_string );

	END LOOP;

END IF; -- l_an_comp_tab.COUNT <> 0


-- ******************** Fast Formula Components *****************************
/*

IF ( l_ff_comp_tab.COUNT <> 0 AND l_continue_evaluation )
THEN

	-- TYPE = FF

	l_ff_ind := l_ff_comp_tab.FIRST;

	WHILE ( l_ff_ind IS NOT NULL AND l_continue_evaluation )
	LOOP

		evaluate_fast_formula (
                            p_formula_id           => l_tc_comp_tab(l_tc_ind).component_type_id
                        ,   p_tc_bb_ok_tab         => p_tc_bb_ok_tab
                        ,   p_tc_bb_ok_string      => p_tc_bb_ok_string
                        ,   p_tc_bb_not_ok_string  => p_tc_bb_not_ok_string );

		l_ff_ind := l_tc_comp_tab.NEXT(l_ff_ind);

		l_continue_evaluation := continue_evaluation ( hxc_time_category_utils_pkg.g_master_tc_info_rec.operator
                                                             , p_tc_bb_ok_string
                                                             , p_tc_bb_not_ok_string );

	END LOOP;

END IF;

*/


-- ******************** Time Category Components *****************************

IF ( l_tc_comp_tab.COUNT <> 0 AND l_continue_evaluation )
THEN

	-- TYPE = TC

	l_tc_ind := l_tc_comp_tab.FIRST;

	WHILE ( l_tc_ind IS NOT NULL AND l_continue_evaluation )
	LOOP

		evaluate_time_category (
                            p_time_category_id     => l_tc_comp_tab(l_tc_ind).ref_tc_id
                        ,   p_tc_bb_ok_tab         => p_tc_bb_ok_tab
                        ,   p_tc_bb_ok_string      => p_tc_bb_ok_string
                        ,   p_tc_bb_not_ok_string  => p_tc_bb_not_ok_string
                        ,   p_use_tc_cache         => g_params.p_use_tc_cache
                        ,   p_use_tc_bb_cache      => g_params.p_use_tc_bb_cache
                        ,   p_use_temp_table       => g_params.p_use_temp_table
                        ,   p_scope                => g_params.p_scope
                        ,   p_tbb_id               => g_params.p_tbb_id
                        ,   p_tbb_ovn              => g_params.p_tbb_ovn );

		l_tc_ind := l_tc_comp_tab.NEXT(l_tc_ind);

	END LOOP;

END IF;


	-- Only maintain these global variables for the master time category

	IF ( p_time_category_id = hxc_time_category_utils_pkg.g_master_tc_info_rec.time_category_id )
	THEN

		-- setting global time category variables

		hxc_time_category_utils_pkg.g_tc_in_bb_ok     := p_time_category_id;
		hxc_time_category_utils_pkg.g_tc_bb_ok_tab    := p_tc_bb_ok_tab;
		hxc_time_category_utils_pkg.g_tc_bb_ok_string := p_tc_bb_ok_string;

		-- *****************************************************************************
		-- bb ok cache is not being used currently
		-- *****************************************************************************

		/*

		IF ( g_debug ) THEN
		hr_utility.trace('Setting tc bb ok cache for master tc !!!! '||to_char(p_time_category_id));
		END IF;

		g_tc_bb_ok_cache(p_time_category_id).bb_ok_string := p_tc_bb_ok_string;

		g_tc_bb_ok_cache(p_time_category_id).timecard_id  :=
        	         hxc_time_category_utils_pkg.g_master_tc_info_rec.time_card_id;

		g_tc_bb_ok_cache(p_time_category_id).attribute_count  :=
	                 hxc_time_category_utils_pkg.g_master_tc_info_rec.attribute_count;

		*/


	END IF;


ELSE -- IF ( NOT l_tc_bb_cache_exists OR NOT p_use_tc_bb_cache )

	-- using the cache

	IF ( g_debug ) THEN
	hr_utility.trace('Using bb outcome cache');
	END IF;

	hxc_time_category_utils_pkg.g_tc_in_bb_ok     := p_time_category_id;

	hxc_time_category_utils_pkg.g_tc_bb_ok_string := g_tc_bb_ok_cache( p_time_category_id ).bb_ok_string;

	hxc_time_category_utils_pkg.g_tc_bb_ok_tab    := get_bb_ok_tab_from_string ( p_time_category_id );

	p_tc_bb_ok_string := g_tc_bb_ok_cache( p_time_category_id ).bb_ok_string;


END IF; -- IF ( NOT l_tc_bb_cache_exists OR NOT p_use_tc_bb_cache )

END IF; -- IF ( NOT l_empty_time_category )

IF ( g_debug ) THEN
hr_utility.trace('***************************************************');
hr_utility.trace('Return values from evaluate time category for : '||to_char(p_time_category_id));
hr_utility.trace('bb ok string     is '||p_tc_bb_ok_string);
hr_utility.trace('bb not ok string is '||p_tc_bb_not_ok_string);
hr_utility.trace('bb ok tab is ....');

l_tc_ind := p_tc_bb_ok_tab.FIRST;

WHILE l_tc_ind IS NOT NULL
LOOP

	hr_utility.trace('bb id is : '||to_char(l_tc_ind));

	l_tc_ind := p_tc_bb_ok_tab.NEXT(l_tc_ind);

END LOOP;
hr_utility.trace('***************************************************');

END IF; -- l debug

-- Reset Variables for the Master TC

IF ( p_time_category_id = hxc_time_category_utils_pkg.g_master_tc_info_rec.time_category_id )
THEN

	-- reset master time category variables now the cache has been maintained

	hxc_time_category_utils_pkg.g_master_tc_info_rec.time_category_id := NULL;

END IF;



exception when others then

IF ( g_debug ) THEN
	hr_utility.trace('In exception error is '||SQLERRM);
END IF;
raise;

END evaluate_time_category;



-- public function
--   chk_tc_bb_ok

-- description
--
--   SEE HEADER FOR DETAILS

FUNCTION chk_tc_bb_ok (
   p_tbb_id   NUMBER ) RETURN BOOLEAN IS

l_proc	VARCHAR2(72);

BEGIN

g_debug := hr_utility.debug_enabled;

IF ( g_debug ) THEN
	l_proc := g_package||'chk_tc_bb_ok';
	hr_utility.set_location('Entering '||l_proc, 10);
END IF;

IF ( (  g_tc_in_bb_ok <> hxc_time_category_utils_pkg.g_time_category_id ) OR
      ( g_tc_in_bb_ok IS NULL ) )
THEN
	IF hxc_time_category_utils_pkg.g_time_category_id is not null then
	    IF g_empty_time_category_tab.exists(hxc_time_category_utils_pkg.g_time_category_id) then
		    IF NOT g_empty_time_category_tab(hxc_time_category_utils_pkg.g_time_category_id).p_status THEN
			    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
			    fnd_message.set_token('PROCEDURE', l_proc);
			    fnd_message.set_token('STEP','g tc id not tc tab id');
			    fnd_message.raise_error;
		    END IF;
	    END IF;
	END IF;
END IF;


IF ( g_tc_bb_ok_tab.EXISTS( p_tbb_id ) )
THEN
	RETURN TRUE;
ELSE
	RETURN FALSE;
END IF;

END chk_tc_bb_ok;



PROCEDURE insert_time_category_comp_sql ( p_rec  hxc_tcc_shd.g_rec_type ) IS

l_proc	VARCHAR2(72);

l_sql      VARCHAR2(32000);
l_operator VARCHAR2(3);

BEGIN

g_debug := hr_utility.debug_enabled;

IF ( g_debug ) THEN
	l_proc := g_package||'insert_time_category_comp_sql';
	hr_utility.set_location('Entering '||l_proc, 10);

	hr_utility.trace('Inserting tcc SQL for type '||p_rec.type);
END IF;

OPEN  csr_get_operator ( p_rec.time_category_id );
FETCH csr_get_operator INTO l_operator;
CLOSE csr_get_operator;

IF ( p_rec.type = 'AN' )
THEN

	alternate_name_string ( p_alias_value_id => p_rec.component_type_id
	              ,         p_operator       => l_operator
		      ,         p_is_null        => p_rec.is_null
	              ,         p_equal_to       => p_rec.equal_to
		      ,         p_time_sql	 => l_sql );

ELSIF ( p_rec.type = 'MC_VS' )
THEN

	value_set_string ( p_rec    => p_rec
                         , p_vs_sql => l_sql );

ELSE

        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','Invalid TYPE');
        fnd_message.raise_error;

END IF;

validate_time_category_sql ( l_sql );

INSERT INTO hxc_time_category_comp_sql (
	time_category_comp_sql_id
,	time_category_comp_id
,	sql_string )
VALUES (
	hxc_time_category_comp_sql_s.nextval
,	p_rec.time_category_comp_id
,	l_sql );

IF ( g_debug ) THEN
	hr_utility.set_location('Entering '||l_proc, 20);
END IF;

END insert_time_category_comp_sql;


PROCEDURE update_time_category_comp_sql ( p_rec            hxc_tcc_shd.g_rec_type ) IS

l_proc	VARCHAR2(72);

l_sql      VARCHAR2(32000);
l_operator VARCHAR2(3);

l_tcc_sql csr_chk_tcc_sql_exists%ROWTYPE;

BEGIN

g_debug := hr_utility.debug_enabled;

IF ( g_debug ) THEN
	l_proc := g_package||'update_time_category_comp_sql';
	hr_utility.trace('Updating tcc SQL for type '||p_rec.type);
END IF;

-- First check to see row exists
-- user may have changed the TYPE of tcc record

OPEN  csr_chk_tcc_sql_exists ( p_rec.time_category_comp_id );
FETCH csr_chk_tcc_sql_exists INTO l_tcc_sql;

IF ( csr_chk_tcc_sql_exists%FOUND )
THEN

	IF ( p_rec.type IN ( 'MC_VS', 'AN' ) )
	THEN

		-- row exists and TCC row still of correct type

		IF ( g_debug ) THEN
			hr_utility.trace('is nul is '||p_rec.is_null);
			hr_utility.trace('equal to is '||p_Rec.equal_to);
		END IF;

		OPEN  csr_get_operator ( p_rec.time_category_id );
		FETCH csr_get_operator INTO l_operator;
		CLOSE csr_get_operator;

		IF ( p_rec.type = 'AN' )
		THEN

			alternate_name_string ( p_alias_value_id => p_rec.component_type_id
			              ,         p_operator       => l_operator
				      ,         p_is_null        => p_rec.is_null
			              ,         p_equal_to       => p_rec.equal_to
				      ,         p_time_sql	 => l_sql );

		ELSIF ( p_rec.type = 'MC_VS' )
		THEN

			value_set_string ( p_rec    => p_rec
		                         , p_vs_sql => l_sql );

		END IF;

		validate_time_category_sql ( l_sql );

		UPDATE hxc_time_category_comp_sql
		SET    sql_string  = l_sql
		WHERE  time_category_comp_id = p_rec.time_category_comp_id;

	ELSE

		-- rows exists but TCC row no longer of type which uses
		-- TCC SQL therefore delete redundant row

		DELETE from hxc_time_category_comp_sql
		WHERE  time_category_comp_sql_id = l_tcc_sql.tcc_sql_id;

	END IF; -- 	IF ( p_rec.type IN ( 'MC_VS', 'AN' )

ELSE

	-- row does not exists

	IF ( p_rec.type in ( 'MC_VS', 'AN' ) )
	THEN

		insert_time_category_comp_sql ( p_rec );

	END IF;


END IF; -- IF ( csr_chk_tcc_sql%FOUND )

CLOSE csr_chk_tcc_sql_exists;

EXCEPTION WHEN OTHERS THEN

CLOSE csr_chk_tcc_sql_exists;
raise;

END update_time_category_comp_sql;


PROCEDURE delete_time_category_comp_sql ( p_rec  hxc_tcc_shd.g_rec_type ) IS

l_proc	VARCHAR2(72);

BEGIN

g_debug := hr_utility.debug_enabled;

IF ( g_debug ) THEN
	l_proc := g_package||'delete_time_category_comp_sql';
	hr_utility.trace('Deleting tcc SQL for type '||p_rec.type);
END IF;

-- First check to see row exists
-- user may have changed the TYPE of tcc record

FOR tcc_sql IN csr_chk_tcc_sql_exists ( p_rec.time_category_comp_id )
LOOP

	DELETE from hxc_time_category_comp_sql
	WHERE  time_category_comp_sql_id = tcc_sql.tcc_sql_id;

END LOOP;


END delete_time_category_comp_sql;

-- ----------------------------------------------------------------------------
-- |----------------------------< get_value_set_sql >-------------------------|
-- ----------------------------------------------------------------------------
--
-- public function
--   get_value_set_sql
--
-- description
--   get the SQL associated with a particular value set


FUNCTION get_value_set_sql
              (p_flex_value_set_id IN NUMBER,
               p_session_date   IN     DATE ) RETURN LONG
is
   --
   -- Declare local variables
   --
   l_sql_text LONG;
   l_sql_text_id LONG;
   l_valueset_r  fnd_vset.valueset_r;
   l_valueset_dr fnd_vset.valueset_dr;
   l_value_set_id fnd_flex_value_sets.flex_value_set_id%TYPE;
   l_proc      varchar2(72);
   l_order_by_start NUMBER;
   l_from_start NUMBER;
   l_additional_and_clause VARCHAR2(2000);
   l_from_where VARCHAR2(2000);
   l_select_clause VARCHAR2(2000);
   l_dep_parent_column_name fnd_columns.column_name%TYPE;
   --
begin -- get_value_set_sql

g_debug := hr_utility.debug_enabled;

IF ( g_debug ) THEN
	l_proc := g_package||'get_value_set_sql';
	hr_utility.set_location('Entering:'|| l_proc, 5);
END IF;


l_value_set_id := p_flex_value_set_id;

   fnd_vset.get_valueset(l_value_set_id,l_valueset_r,l_valueset_dr);

--
-- Initailize the SQL text columns.
--
   l_sql_text := '';
   l_sql_text_id := '';
   --
   IF ( g_debug ) THEN
   	hr_utility.set_location(l_proc, 10);
   END IF;

-- Ok next build the SQL text that can be used to build a pop-list
-- for this segment, if this is a table validated or independant
-- validated value set - i.e. it has an associated list of values.
-- We are going to build two versions of the SQL.  One can be used
-- to define the list of values associated with this segment(SQL_TEXT), the
-- other is used to converted a value (ID) stored on the database into a
-- a description (VALUE) (SQL_DESCR_TXT).
--
IF l_valueset_r.validation_type = 'F'
THEN
	-- TABLE validated

   IF ( g_debug ) THEN
   	hr_utility.set_location(l_proc, 20);
   END IF;

      select 'SELECT ' ||
          l_valueset_r.table_info.value_column_name ||
          decode(l_valueset_r.table_info.meaning_column_name,null,',NULL ',
                 ','||l_valueset_r.table_info.meaning_column_name)||
          decode(l_valueset_r.table_info.id_column_name,null,',NULL ',
                 ','||l_valueset_r.table_info.id_column_name)||
                 ' FROM ' ||
                 l_valueset_r.table_info.table_name || ' ' ||
                 l_valueset_r.table_info.where_clause
      into l_sql_text
      from dual;

   IF ( g_debug ) THEN
   	hr_utility.set_location(l_proc, 30);
   END IF;

      l_order_by_start := INSTR(upper(l_sql_text),'ORDER BY');
      l_from_start := INSTR(upper(l_sql_text),'FROM');

   IF ( g_debug ) THEN
   	hr_utility.set_location(l_proc, 60);
   END IF;

-- Build the SQL for the FROM clause

      if(l_order_by_start >0) then
          l_from_where := substr(l_sql_text,l_from_start,(
                                            l_order_by_start-l_from_start));
      else
          l_from_where := substr(l_sql_text,l_from_start);
      end if;
--
   IF ( g_debug ) THEN
   	hr_utility.set_location(l_proc, 90);
   END IF;
--
      if(l_valueset_r.table_info.meaning_column_name is not null) then
        l_select_clause := 'SELECT '||l_valueset_r.table_info.
                                                    meaning_column_name||' ';
      else
        l_select_clause := 'SELECT '||l_valueset_r.table_info.
                                                      value_column_name||' ';
      end if;

     l_sql_text_id := l_select_clause||l_from_where;

	IF ( INSTR( UPPER(l_sql_text_id) , 'WHERE') = 0 )
	THEN

     l_sql_text_id   := l_select_clause||l_from_where ||'WHERE '||l_valueset_r.table_info.id_column_name||' = ';

	ELSE

     l_sql_text_id   := l_select_clause||l_from_where ||' and '||l_valueset_r.table_info.id_column_name||' = ';

	END IF;


   elsif l_valueset_r.validation_type = 'I' then

   IF ( g_debug ) THEN
   	hr_utility.set_location(l_proc, 120);
   END IF;
--
-- We can hard code the DESC SQL this time, since we know explicitly
-- how independant value sets are built.  This should be changed once
-- we have the procedure from AOL.
--
         l_sql_text_id := 'SELECT FLEX_VALUE'||
                       ' FROM FND_FLEX_VALUES_VL'||
                       ' WHERE FLEX_VALUE_SET_ID =' || l_value_set_id ||
                       ' AND ENABLED_FLAG = ''Y'''||
                       ' AND '''||P_SESSION_DATE||''' BETWEEN'||
                       ' NVL(START_DATE_ACTIVE,'''||
                                     P_SESSION_DATE||''')'||
                       ' AND NVL(END_DATE_ACTIVE,'''||
                                     P_SESSION_DATE||''')'||
                       ' AND FLEX_VALUE = ';

   else

	-- should only be table or independent value sets

	fnd_message.set_name(809,'HXC_GAZ_VALUE_SET_CHANGED');

   end if; -- validation type

   IF ( g_debug ) THEN
   	hr_utility.set_location(' Leaving:'||l_proc, 150);
   END IF;

RETURN l_sql_text_id;

end get_value_set_sql;


-- public procedure
--   get_flex_info
--
-- description
--   get flex field context segment info. In particular information
--   on the validation and value set associated with each segment
--   within the context
--   Used in the Time Categories form to dynamically set the LOV associated
--   with each mapping component chosen.

PROCEDURE get_flex_info (
		p_context_code    IN  VARCHAR2
        ,       p_seg_info        OUT NOCOPY t_seg_info
        ,       p_session_date    IN  DATE ) IS

l_proc 	varchar2(72);
r_segments_t hr_flexfield_info.hr_segments_info; -- remember this is a record of tables
l_t_seg_info t_seg_info; -- local table

l_where LONG;
l_upper_where LONG;

FUNCTION parse_sql ( p_sql LONG ) RETURN LONG IS

l_proc 	varchar2(72);

l_sql_text LONG;

BEGIN


IF ( g_debug ) THEN
	l_proc := g_package||'parse_sql';
	hr_utility.set_location('Processing:'||l_proc, 5);
END IF;

l_sql_text :=
  REPLACE(UPPER(
  SUBSTR(p_sql ,1,INSTR(p_sql,',',1,1)-1)||' A,'||
  SUBSTR(p_sql ,INSTR(p_sql,',',1,1)+1, ( (INSTR(p_sql,',',1,2)) - (INSTR(p_sql,',',1,1)+1) ))||' B,TO_CHAR('||
  SUBSTR(p_sql ,INSTR(p_sql,',',1,2)+1)), 'FROM', ') C FROM');

IF ( g_debug ) THEN
	hr_utility.set_location('Processing:'||l_proc, 10);
END IF;

RETURN l_sql_text;

END parse_sql;

BEGIN -- get_flex_info

g_debug := hr_utility.debug_enabled;

IF ( g_debug ) THEN
	l_proc := g_package||'get_flex_info';
	hr_utility.set_location('Processing:'||l_proc, 5);
END IF;

hr_flexfield_info.initialize;

IF ( g_debug ) THEN
	hr_utility.set_location('Processing:'||l_proc, 10);
END IF;

hr_flexfield_info.get_segments (
		p_appl_short_name => 'HXC'
       ,        p_flexfield_name  => 'OTC Information Types'
       ,        p_context_code    => p_context_code
       ,        p_enabled_only    => TRUE
       ,        p_segments        => r_segments_t
       ,        p_session_date    => p_session_date );

IF ( g_debug ) THEN
	hr_utility.set_location('Processing:'||l_proc, 20);
END IF;

-- reduce r_segments_t to l_r_seg_info_t

FOR x IN r_segments_t.sequence.FIRST .. r_segments_t.sequence.LAST
LOOP
	IF ( g_debug ) THEN
		hr_utility.set_location('Processing:'||l_proc, 30);
	END IF;

	l_t_seg_info(x).application_column_name := r_segments_t.application_column_name(x);
        l_t_seg_info(x).segment_name            := r_segments_t.segment_name(x);
        l_t_seg_info(x).column_prompt           := r_segments_t.column_prompt(x);
        l_t_seg_info(x).value_set               := r_segments_t.value_set(x);
        l_t_seg_info(x).validation_type         := r_segments_t.validation_type(x);
        l_t_seg_info(x).sql_text                := r_segments_t.sql_text(x);

	l_where       := NULL;
	l_upper_where := NULL;

-- if value set not table or list or SQL has any $FLEX$ or $PROFILE$ references
-- then we cannot use this to set the record group in the form

IF ( g_debug ) THEN
	hr_utility.trace('SQL is '||l_t_seg_info(x).sql_text);
END IF;

	IF ( l_t_seg_info(x).validation_type = 'NONE' OR l_t_seg_info(x).value_set IS NULL )
	THEN
		IF ( g_debug ) THEN
			hr_utility.trace('validation type NONE');
		END IF;

	        l_t_seg_info(x).sql_ok := FALSE;
	        l_t_seg_info(x).no_sql := TRUE;

	ELSIF ( l_t_seg_info(x).validation_type = 'INDEPENDENT')
	THEN
		IF ( g_debug ) THEN
			hr_utility.trace('validation type INDEPENDENT');
		END IF;

		l_t_seg_info(x).sql_text := parse_sql ( l_t_seg_info(x).sql_text );
		l_t_seg_info(x).sql_ok := TRUE;
	ELSE
		IF ( g_debug ) THEN
			hr_utility.trace('validation type '||l_t_seg_info(x).validation_type);
		END IF;

		l_t_seg_info(x).sql_text := parse_sql ( l_t_seg_info(x).sql_text );

	        chk_profile_flex( l_t_seg_info(x).value_set
                                , l_where
                                , l_t_seg_info(x).sql_ok);

		IF ( l_where IS NOT NULL )
		THEN

			l_upper_where := UPPER(l_where);

			l_t_seg_info(x).sql_text := REPLACE(l_t_seg_info(x).sql_text, l_upper_where, l_where);

		END IF;

	END IF;

END LOOP;

	IF ( g_debug ) THEN
		hr_utility.set_location('Processing:'||l_proc, 40);
	END IF;

	p_seg_info := l_t_seg_info;

END get_flex_info;



-- public function
--   get_flex_value
--
-- description
--   retrieves the value based on the id and flex value set id
--   used in the hxc_time_category_comps_v view.

FUNCTION get_flex_value (  p_flex_value_set_id NUMBER
	,		p_id  VARCHAR2 ) RETURN VARCHAR2 IS

l_sql LONG;
l_description VARCHAR2(150) := NULL;

-- GPM v115.26

CURSOR csr_get_element_name ( p_element_type_id VARCHAR2 ) IS
select   pett.element_name Display_Value
from     pay_element_types_f_tl pett
where pett.element_type_id = p_element_type_id
and   pett.language = USERENV('LANG');

l_csr INTEGER;

BEGIN

g_debug := hr_utility.debug_enabled;

IF ( p_flex_value_set_id = -1 )
THEN

-- no value set therefore at the moment is 'Dummy Element Context'

OPEN  csr_get_element_name ( p_id );
FETCH csr_get_element_name INTO l_description;
CLOSE csr_get_element_name;

ELSIF ( p_flex_value_set_id = -2 )
THEN

-- no value set at all -free form text Valeu = Value_Id

	l_description := p_id;

ELSE

IF ( g_debug ) THEN
	hr_utility.trace('gaz - before');
END IF;

l_sql := get_value_set_sql (
	p_flex_value_set_id => p_flex_value_set_id
,       p_session_date => sysdate );

IF ( g_debug ) THEN
	hr_utility.trace('gaz - before');
	hr_utility.trace('gaz - l sql is '||l_sql);
	hr_utility.trace('gaz - p_id is '||p_id);
END IF;

BEGIN

	execute immediate l_sql||''''||p_id||'''' INTO l_description;

EXCEPTION WHEN OTHERS THEN

-- GPM v115.12 WWB 3254482
-- for customers who modify the value sets
-- which allow duplicate entries !!!

	IF SQLCODE = -1422 -- exact fetch returns more then one row
	THEN
		null;
	ELSE
		raise;
	END IF;
END;

END IF;

RETURN l_description;

END get_flex_value;


-- prublic function
--   get_time_category_id
--
-- description
--   get time category id based on time category name

FUNCTION get_time_category_id ( p_time_category_name VARCHAR2 ) RETURN NUMBER IS

CURSOR csr_get_time_category_id IS
SELECT htc.time_category_id
FROM   hxc_time_categories htc
WHERE  htc.time_category_name = p_time_category_name;

l_time_category_id hxc_time_categories.time_category_id%TYPE;

BEGIN

OPEN  csr_get_time_category_id;
FETCH csr_get_time_category_id INTO l_time_category_id;
CLOSE csr_get_time_category_id;

RETURN l_time_category_id;

END get_time_category_id;



-- PUBLIC function for backward compatibility with Phase I Time Categories

PROCEDURE initialise_time_category (
                        p_time_category_id NUMBER
               ,        p_tco_att   hxc_self_service_time_deposit.building_block_attribute_info ) IS

l_tc_bb_ok_tab        hxc_time_category_utils_pkg.g_tc_bb_ok_tab%TYPE;
l_tc_bb_ok_string     VARCHAR2(32000);
l_tc_bb_not_ok_string VARCHAR2(32000);

l_proc	VARCHAR2(72);


BEGIN

g_debug := hr_utility.debug_enabled;

g_tc_bb_ok_tab.delete;


-- Bug 6710408
-- Put down the below statements to explicitly NULL out the master
-- time category info record elements. Had this change when customer
-- complained of some value getting preloaded here, making the process
-- error out.
-- Added few extra trace messages too, for clarity in future.

hxc_time_category_utils_pkg.g_master_tc_info_rec.time_category_id := NULL;
hxc_time_category_utils_pkg.g_master_tc_info_rec.time_card_id     := NULL;
hxc_time_category_utils_pkg.g_master_tc_info_rec.operator         := NULL;
hxc_time_category_utils_pkg.g_master_tc_info_rec.attribute_count  := NULL;



IF ( g_debug ) THEN
	l_proc := g_package||'initialise_time_category';
	hr_utility.set_location('Entering '||l_proc, 10);
	hr_utility.trace('Initialise_time_category for time_category_id :'||p_time_category_id);
	hr_utility.trace('Assigned NULL to the master tc id record ');
END IF;

hxc_time_category_utils_pkg.evaluate_time_category (
                                   p_time_category_id     => p_time_category_id
                               ,   p_tc_bb_ok_tab         => l_tc_bb_ok_tab
                               ,   p_tc_bb_ok_string      => l_tc_bb_ok_string
                               ,   p_tc_bb_not_ok_string  => l_tc_bb_not_ok_string );

IF ( g_debug ) THEN
	hr_utility.set_location('Leaving '||l_proc, 20);
END IF;

END initialise_time_category;


-- PUBLIC function for backward compatibility with Phase I Time Categories

PROCEDURE initialise_time_category (
                        p_time_category_id NUMBER
               ,        p_tco_att   hxc_attribute_table_type ) IS

l_dummy_att hxc_self_service_time_deposit.building_block_attribute_info;

BEGIN

initialise_time_category (
                        p_time_category_id => p_time_category_id
               ,        p_tco_att          => l_dummy_att );

END initialise_time_category;



-- public function
--   category_timecard_hrs
--
-- description
--   Returns the number of hours for timecard
--   for a specified time category name

FUNCTION category_timecard_hrs (
		p_tbb_id	NUMBER
	,	p_tbb_ovn	NUMBER
	,       p_time_category_name VARCHAR2 ) RETURN NUMBER IS

CURSOR csr_sum_all_timecard_hrs ( p_tbb_id NUMBER, p_tbb_ovn NUMBER ) IS
SELECT SUM( DECODE( detail.type, 'RANGE',
       (((detail.stop_time)-(detail.start_time))*24),
        NVL(detail.measure, 0) )) hrs
FROM hxc_latest_details tbb_latest,
     hxc_time_building_blocks detail,
     hxc_time_building_blocks day
where day.parent_building_block_id  = p_tbb_id
  and day.parent_building_block_ovn = p_tbb_ovn
  and detail.parent_building_block_id =
      day.time_building_block_id
  and detail.parent_building_block_ovn =
      day.object_version_number
  and tbb_latest.time_building_block_id = detail.time_building_Block_id
  and tbb_latest.object_version_number  = detail.object_version_number
  and detail.date_to = hr_general.end_of_time;


l_timecard_hrs NUMBER := 0;
l_time_category_id hxc_time_categories.time_category_id%TYPE;

l_tc_bb_ok_tab        hxc_time_category_utils_pkg.t_tc_bb_ok;
l_tc_bb_ok_string     VARCHAR2(32000);
l_tc_bb_not_ok_string VARCHAR2(32000);

l_proc      varchar2(72);

BEGIN

g_debug := hr_utility.debug_enabled;

IF ( g_debug ) THEN
	l_proc := g_package||'category_timecard_hrs';
	hr_utility.set_location('Entering '||l_proc, 10);

	hr_utility.trace('gaz - time cat id is  '||p_time_category_name);
END IF;

IF ( p_time_category_name is not null )
THEN

l_time_category_id := get_time_category_id ( p_time_category_name => p_time_category_name );

IF ( g_debug ) THEN
	hr_utility.trace('gaz - time cat id is  '||to_char(l_time_category_id));
	hr_utility.trace('gaz - time bb id is   '||to_char(p_tbb_id));
	hr_utility.trace('gaz - time ovn id is  '||to_char(p_tbb_ovn));

	hr_utility.set_location('Processing '||l_proc, 20);
END IF;

-- call evaluate time category with p_scope = 'DETAIL'

        evaluate_time_category (
                                   p_time_category_id     => l_time_category_id
                               ,   p_tc_bb_ok_tab         => l_tc_bb_ok_tab
                               ,   p_tc_bb_ok_string      => l_tc_bb_ok_string
                               ,   p_tc_bb_not_ok_string  => l_tc_bb_not_ok_string
                               ,   p_use_temp_table       => FALSE
                               ,   p_scope                => 'TIME'
                               ,   p_tbb_id               => p_tbb_id
                               ,   p_tbb_ovn              => p_tbb_ovn );

         sum_live_tc_bb_ok_hrs ( p_tc_bb_ok_string   => l_tc_bb_ok_string
                               , p_hrs               => l_timecard_hrs );

ELSE

	OPEN  csr_sum_all_timecard_hrs ( p_tbb_id => p_tbb_id, p_tbb_ovn => p_tbb_ovn );
	FETCH csr_sum_all_timecard_hrs INTO l_timecard_hrs;
	CLOSE csr_sum_all_timecard_hrs;

END IF;

IF ( g_debug ) THEN
	hr_utility.trace('l timecard hrs are '||to_char(NVL( l_timecard_hrs, 0 ) ));
	hr_utility.set_location('Leaving '||l_proc, 30);
END IF;

RETURN NVL(l_timecard_hrs, 0);

END category_timecard_hrs;


--Similar to above
--needed because we have to process each detail block
--individually according to precision and rounding rule

FUNCTION category_timecard_hrs_ind (
		p_tbb_id	NUMBER
	,	p_tbb_ovn	NUMBER
	,       p_time_category_name VARCHAR2 ) RETURN NUMBER IS

CURSOR csr_timecard_hrs ( p_tbb_id NUMBER, p_tbb_ovn NUMBER ) IS
SELECT  DECODE( detail.type, 'RANGE',
       nvl((((detail.stop_time)-(detail.start_time))*24),0),
        NVL(detail.measure, 0) ) hrs
FROM hxc_latest_details tbb_latest,
     hxc_time_building_blocks detail,
     hxc_time_building_blocks day
where day.parent_building_block_id  = p_tbb_id
  and day.parent_building_block_ovn = p_tbb_ovn
  and detail.parent_building_block_id =
      day.time_building_block_id
  and detail.parent_building_block_ovn =
      day.object_version_number
  and tbb_latest.time_building_block_id = detail.time_building_Block_id
  and tbb_latest.object_version_number  = detail.object_version_number
  and detail.date_to = hr_general.end_of_time;

CURSOR c_tc_resource_id(
			p_tc_bbid hxc_time_building_blocks.time_building_block_id%TYPE,
			p_tbb_ovn hxc_time_building_blocks.object_version_number%TYPE
		       )IS
SELECT tbb.resource_id
FROM   hxc_time_building_blocks tbb
WHERE  tbb.time_building_block_id = p_tc_bbid
AND    tbb.object_version_number = p_tbb_ovn;

/* Bug fix for 5526281 */
CURSOR get_timecard_start_date(
			       p_tc_bbid hxc_time_building_blocks.time_building_block_id%TYPE,
			       p_tc_ovnid hxc_time_building_blocks.object_version_number%TYPE
			      ) IS
SELECT tbb.start_time,tbb.stop_time
FROM   hxc_time_building_blocks tbb
WHERE  tbb.time_building_block_id = p_tc_bbid
AND    tbb.object_version_number = p_tc_ovnid;

cursor emp_hire_info(p_resource_id hxc_time_building_blocks.resource_id%TYPE) IS
select date_start from per_periods_of_service where person_id=p_resource_id order by date_start desc;
/* end of bug fix for 5526281 */

l_timecard_hrs NUMBER := 0;
l_time_category_id hxc_time_categories.time_category_id%TYPE;

l_tc_bb_ok_tab        hxc_time_category_utils_pkg.t_tc_bb_ok;
l_tc_bb_ok_string     VARCHAR2(32000);
l_tc_bb_not_ok_string VARCHAR2(32000);

l_precision       VARCHAR2(4);
l_rounding_rule   VARCHAR2(20);
l_index           NUMBER :=1;
l_resource_id     NUMBER;
l_tc_start_date   DATE;

/* Bug fix for 5526281 */
l_tc_end_date           date;
l_pref_eval_date	date;
l_emp_hire_date		date;
/* end of bug fix for 5526281 */

l_proc      varchar2(72);

BEGIN

g_debug := hr_utility.debug_enabled;

open c_tc_resource_id(p_tbb_id, p_tbb_ovn);
fetch c_tc_resource_id into l_resource_id;
close c_tc_resource_id;

/* Bug fix for 5526281 */
OPEN  get_timecard_start_date (p_tbb_id, p_tbb_ovn);
FETCH get_timecard_start_date into l_tc_start_date,l_tc_end_date;
CLOSE get_timecard_start_date;

OPEN  emp_hire_info (l_resource_id);
FETCH emp_hire_info into l_emp_hire_date;
CLOSE emp_hire_info;

if trunc(l_emp_hire_date) >= trunc(l_tc_start_date) and trunc(l_emp_hire_date) <= trunc(l_tc_end_date) then
	l_pref_eval_date := trunc(l_emp_hire_date);
else
	l_pref_eval_date := trunc(l_tc_start_date);
end if;

l_precision := hxc_preference_evaluation.resource_preferences
                                                (l_resource_id,
                                                 'TC_W_TCRD_UOM',
                                                 3,
                                                 l_pref_eval_date
                                                );

l_rounding_rule := hxc_preference_evaluation.resource_preferences
                                                (l_resource_id,
                                                 'TC_W_TCRD_UOM',
                                                 4,
                                                 l_pref_eval_date
                                                );
/* end of bug fix for 5526281 */
if l_precision is null
then
l_precision := '2';
end if;

if l_rounding_rule is null
then
l_rounding_rule := 'ROUND_TO_NEAREST';
end if;

IF ( p_time_category_name is not null )
THEN

l_time_category_id := get_time_category_id ( p_time_category_name => p_time_category_name );

-- call evaluate time category with p_scope = 'DETAIL'

        evaluate_time_category (
                                   p_time_category_id     => l_time_category_id
                               ,   p_tc_bb_ok_tab         => l_tc_bb_ok_tab
                               ,   p_tc_bb_ok_string      => l_tc_bb_ok_string
                               ,   p_tc_bb_not_ok_string  => l_tc_bb_not_ok_string
                               ,   p_use_temp_table       => FALSE
                               ,   p_scope                => 'TIME'
                               ,   p_tbb_id               => p_tbb_id
                               ,   p_tbb_ovn              => p_tbb_ovn );


         sum_live_tc_bb_ok_hrs( p_tc_bb_ok_string   => l_tc_bb_ok_string
                              , p_hrs               => l_timecard_hrs
			      , p_rounding_rule     => l_rounding_rule
			      , p_decimal_precision => l_precision);

ELSE

	for hrs_rec in csr_timecard_hrs(p_tbb_id,p_tbb_ovn) loop

	 l_timecard_hrs := l_timecard_hrs + hxc_find_notify_aprs_pkg.apply_round_rule(
                                            l_rounding_rule,
					    l_precision,
                                            nvl(hrs_rec.hrs,0)
					    );

	 l_index := l_index +1;
        end loop;

END IF;

RETURN NVL(l_timecard_hrs, 0);

END category_timecard_hrs_ind;




-- public function
--   category_detail_hrs (Overloaded)
--
-- description
--   Returns the number of hours for 1 DETAIL time building block
--   for a specified time category name

FUNCTION category_detail_hrs (
		p_tbb_id	NUMBER
	,	p_tbb_ovn	NUMBER
	,       p_time_category_name VARCHAR2 ) RETURN NUMBER IS

l_timecard_hrs NUMBER;
l_time_category_id hxc_time_categories.time_category_id%TYPE;

BEGIN

l_time_category_id := get_time_category_id ( p_time_category_name => p_time_category_name );

l_timecard_hrs := category_detail_hrs (
		p_tbb_id  => p_tbb_id
	,	p_tbb_ovn => p_tbb_ovn
	,	p_time_category_id => l_time_category_id );

RETURN l_timecard_hrs;

END category_detail_hrs;



-- public function
--   category_detail_hrs (Overloaded)
--
-- description
--   Returns the number of hours for 1 DETAIL time building block
--   (the global variable g time category id is presumed to be set)

FUNCTION category_detail_hrs (
		p_tbb_id	NUMBER
	,	p_tbb_ovn	NUMBER ) RETURN NUMBER IS

l_timecard_hrs NUMBER;

BEGIN

l_timecard_hrs := category_detail_hrs (
		p_tbb_id  => p_tbb_id
	,	p_tbb_ovn => p_tbb_ovn
	,	p_time_category_id => hxc_time_category_utils_pkg.g_time_category_id );

RETURN l_timecard_hrs;

END category_detail_hrs;




-- public function
--   category_detail_hrs
--
-- description
--   Returns the number of hours for 1 DETAIL time building block
--   for a specified time category id

FUNCTION category_detail_hrs (
		p_tbb_id	NUMBER
	,	p_tbb_ovn	NUMBER
	,       p_time_category_id NUMBER ) RETURN NUMBER IS

l_hrs      NUMBER := 0;
l_proc	   VARCHAR2(72);

l_tc_bb_ok_tab        hxc_time_category_utils_pkg.t_tc_bb_ok;
l_tc_bb_ok_string     VARCHAR2(32000);
l_tc_bb_not_ok_string VARCHAR2(32000);


CURSOR  csr_calc_all IS
SELECT
      SUM(NVL(tbb.measure,0) +
      ((( NVL(tbb.stop_time,sysdate) - NVL(tbb.start_time,sysdate))*24)))
FROM
      hxc_time_building_blocks tbb
WHERE
      tbb.time_building_block_id = p_tbb_id AND
      tbb.object_version_number  = p_tbb_ovn;


BEGIN
g_debug := hr_utility.debug_enabled;

IF ( g_debug ) THEN
	l_proc := g_package||'category_detail_hrs';
	hr_utility.set_location('Entering '||l_proc, 10);
END IF;

IF ( p_time_category_id IS NULL )
THEN
	IF ( g_debug ) THEN
		hr_utility.set_location('Processing '||l_proc, 20);
	END IF;

	OPEN  csr_calc_all;
	FETCH csr_calc_all INTO l_hrs;
	CLOSE csr_calc_all;

ELSE

	IF ( g_debug ) THEN
		hr_utility.set_location('Processing '||l_proc, 30);
	END IF;

	-- call evaluate time category with p_scope = 'DETAIL'

        evaluate_time_category (
                                   p_time_category_id     => p_time_category_id
                               ,   p_tc_bb_ok_tab         => l_tc_bb_ok_tab
                               ,   p_tc_bb_ok_string      => l_tc_bb_ok_string
                               ,   p_tc_bb_not_ok_string  => l_tc_bb_not_ok_string
                               ,   p_use_tc_bb_cache      => FALSE
                               ,   p_use_temp_table       => FALSE
                               ,   p_scope                => 'DETAIL'
                               ,   p_tbb_id               => p_tbb_id
                               ,   p_tbb_ovn              => p_tbb_ovn );

         sum_live_tc_bb_ok_hrs ( p_tc_bb_ok_string   => l_tc_bb_ok_string
                               , p_hrs               => l_hrs );

END IF;

IF ( g_debug ) THEN
	hr_utility.set_location('Leaving '||l_proc, 60);
END IF;

RETURN NVL(l_hrs,0);

END category_detail_hrs;





-- public function
--   category_app_period_tc_hrs
--
-- description
--   Returns the number of hours for person within a date range
--   and specified time category and application_period_id

FUNCTION category_app_period_tc_hrs (
		p_period_start_time     IN DATE
	,	p_period_stop_time      IN DATE
	,	p_resource_id           IN NUMBER
	,       p_time_category_name    IN VARCHAR2
        ,       p_application_period_id IN NUMBER ) RETURN NUMBER IS

l_time_category_id hxc_time_categories.time_category_id%TYPE;
l_hours       NUMBER := 0;
l_total_hours NUMBER :=0;
l_precision   VARCHAR2(4);
l_rounding_rule VARCHAR2(20);

CURSOR  csr_get_total_timecard_hrs IS
SELECT	NVL( hours_worked, 0 )
FROM	hxc_app_period_total_time_v
WHERE	resource_id = p_resource_id
AND	start_date BETWEEN p_period_start_time AND p_period_stop_time
AND	stop_date  BETWEEN p_period_start_time AND p_period_stop_time
AND     application_period_id = p_application_period_id;

 BEGIN

 g_debug := hr_utility.debug_enabled;

 IF ( g_debug ) THEN
 	hr_utility.trace('period_start_time is  '||to_char(p_period_start_time, 'dd-mon-yy'));
 	hr_utility.trace('period_end_time   is  '||to_char(p_period_stop_time, 'dd-mon-yy'));
 	hr_utility.trace('resource id      is   '||to_char(p_resource_id));
 	hr_utility.trace('app period id    is   '||to_char(p_application_period_id));
 	hr_utility.trace('time category name is '||p_time_category_name);
 END IF;

 l_precision := hxc_preference_evaluation.resource_preferences
                                                 (p_resource_id,
                                                  'TC_W_TCRD_UOM',
                                                  3,
                                                  p_period_start_time
                                                 );

 l_rounding_rule := hxc_preference_evaluation.resource_preferences
                                                 (p_resource_id,
                                                  'TC_W_TCRD_UOM',
                                                  4,
                                                  p_period_start_time
                                                 );
if l_precision is null
then
l_precision := '2';
end if;

if l_rounding_rule is null
then
l_rounding_rule := 'ROUND_TO_NEAREST';
end if;

hxc_time_category_utils_pkg.g_time_category_id :=
get_time_category_id ( p_time_category_name => p_time_category_name );

OPEN  csr_get_total_timecard_hrs;
FETCH csr_get_total_timecard_hrs INTO l_hours;

WHILE csr_get_total_timecard_hrs%FOUND
LOOP

	l_total_hours := l_total_hours + hxc_find_notify_aprs_pkg.apply_round_rule(
                                            l_rounding_rule,
					    l_precision,
                                            l_hours
					    );

	FETCH csr_get_total_timecard_hrs INTO l_hours;

END LOOP;

CLOSE csr_get_total_timecard_hrs;

RETURN l_total_hours;

END category_app_period_tc_hrs;




-- public procedure
--   process_tc_timecard
--
-- description
--
--   SEE HEADER FOR DETAILS

PROCEDURE process_tc_timecard (
   p_tco_att   hxc_self_service_time_deposit.building_block_attribute_info
,  p_time_cat  t_time_category
,  p_bb_ok_tab IN OUT NOCOPY t_tc_bb_ok
,  p_operator  VARCHAR2 default 'OR' ) IS

l_proc	VARCHAR2(72) := g_package||'process_tc_timecard';

BEGIN

        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','Procedure redundant use evaluate_time_category');
        fnd_message.raise_error;

END process_tc_timecard;


PROCEDURE time_category_string ( p_time_category_id NUMBER
			,	 p_dyn_or_tab	    IN VARCHAR2
			,	 p_dyn_sql	    IN OUT NOCOPY LONG
			,        p_category_tab     IN OUT NOCOPY t_time_category
                        ,        p_operator         IN OUT NOCOPY VARCHAR2 ) IS

   l_proc      varchar2(72) := g_package||'time_category_string';

BEGIN

        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','Procedure redundant use evaluate_time_category');
        fnd_message.raise_error;

END time_category_string;



PROCEDURE alias_value_ref_int_chk ( p_alias_value_id NUMBER
                                  , p_action         VARCHAR2 ) IS

CURSOR  csr_get_time_category IS
SELECT
	htc.time_category_name
,       tcc.time_category_comp_id
,       tcc.time_category_id
,       tcc.ref_time_category_id
,       tcc.component_type_id
,       tcc.flex_value_set_id
,       tcc.value_id
,       tcc.is_null
,       tcc.equal_to
,       tcc.type
,       tcc.object_version_number
FROM    hxc_time_categories htc
,	hxc_time_category_comps tcc
WHERE   tcc.time_category_id = htc.time_category_id
AND	tcc.type = 'AN'
AND	tcc.component_type_id = p_alias_value_id
ORDER BY htc.time_category_id;

l_time_category_name hxc_time_categories.time_category_name%TYPE;

l_rec hxc_tcc_shd.g_rec_type;

BEGIN

FOR tc IN csr_get_time_category
LOOP

	IF ( p_action = 'DELETE' )
	THEN

		IF ( l_time_category_name IS NULL )
		THEN

			l_time_category_name := tc.time_category_name;

		ELSE

			l_time_category_name := l_time_category_name||', '||tc.time_category_name;

		END IF;

	ELSE

		-- must be update

		l_rec.time_category_comp_id	:= tc.time_category_comp_id;
		l_rec.time_category_id		:= tc.time_category_id;
		l_rec.ref_time_category_id	:= tc.ref_time_category_id;
		l_rec.component_type_id		:= tc.component_type_id;
		l_rec.flex_value_set_id		:= tc.flex_value_set_id;
		l_rec.value_id			:= tc.value_id;
		l_rec.is_null			:= tc.is_null;
		l_rec.equal_to			:= tc.equal_to;
		l_rec.type			:= tc.type;
		l_rec.object_version_number	:= tc.object_version_number;

		update_time_category_comp_sql ( l_rec );

	END IF;

END LOOP;

IF ( l_time_category_name IS NOT NULL )
THEN

                fnd_message.set_name('HXC', 'HXC_HTC_ALIAS_REF_INT_CHECK');
                fnd_message.set_token('TC_NAME', l_time_category_name );
                fnd_message.raise_error;

END IF;


END alias_value_ref_int_chk;



PROCEDURE alias_definition_ref_int_chk ( p_alias_definition_id NUMBER ) IS

CURSOR  csr_get_time_category IS
SELECT	htc.time_category_name
FROM    hxc_time_categories htc
,	hxc_time_category_comps tcc
,       hxc_alias_values av
,       hxc_alias_definitions ad
WHERE
	ad.alias_definition_id = p_alias_definition_id
AND
	av.alias_definition_id = ad.alias_definition_id
AND
	tcc.component_type_id = av.alias_value_id AND
	tcc.type              = 'AN'
AND
	tcc.time_category_id = htc.time_category_id;

l_time_category_name hxc_time_categories.time_category_name%TYPE;


BEGIN

FOR tc IN csr_get_time_category
LOOP

	IF ( l_time_category_name IS NULL )
	THEN

		l_time_category_name := tc.time_category_name;

	ELSE

		l_time_category_name := l_time_category_name||', '||tc.time_category_name;

	END IF;

END LOOP;


IF ( l_time_category_name IS NOT NULL )
THEN

                fnd_message.set_name('HXC', 'HXC_HTC_ALIAS_REF_INT_CHECK');
                fnd_message.set_token('TC_NAME', l_time_category_name );
                fnd_message.raise_error;

END IF;




null;

END alias_definition_ref_int_chk;



PROCEDURE alias_type_comp_ref_int_chk ( p_alias_type_id NUMBER ) IS

CURSOR  csr_get_time_category_comps IS
SELECT
        tcc.time_category_comp_id
,       tcc.time_category_id
,       tcc.ref_time_category_id
,       tcc.component_type_id
,       tcc.flex_value_set_id
,       tcc.value_id
,       tcc.is_null
,       tcc.equal_to
,       tcc.type
,       tcc.object_version_number
FROM    hxc_time_category_comps tcc
,       hxc_alias_values av
,       hxc_alias_definitions ad
,       hxc_alias_types hat
WHERE
	hat.alias_type_id            = p_alias_type_id
AND
	ad.alias_type_id            = hat.alias_type_id
AND
	av.alias_definition_id = ad.alias_definition_id
AND
	tcc.component_type_id = av.alias_value_id AND
	tcc.type              = 'AN';

l_rec hxc_tcc_shd.g_rec_type;

BEGIN

g_debug := hr_utility.debug_enabled;

IF ( g_debug ) THEN
	hr_utility.trace('In ref chk');
END IF;

FOR tc IN csr_get_time_category_comps
LOOP

	l_rec.time_category_comp_id	:= tc.time_category_comp_id;
	l_rec.time_category_id		:= tc.time_category_id;
	l_rec.ref_time_category_id	:= tc.ref_time_category_id;
	l_rec.component_type_id		:= tc.component_type_id;
	l_rec.flex_value_set_id		:= tc.flex_value_set_id;
	l_rec.value_id			:= tc.value_id;
	l_rec.is_null			:= tc.is_null;
	l_rec.equal_to			:= tc.equal_to;
	l_rec.type			:= tc.type;
	l_rec.object_version_number	:= tc.object_version_number;

	IF ( g_debug ) THEN
		hr_utility.trace('about to call update');
	END IF;

	update_time_category_comp_sql ( l_rec );

END LOOP;

END alias_type_comp_ref_int_chk;
--
-- ---------------------------------------------------------------------------
-- |------------------------< reset_cache >----------------------------------|
-- ---------------------------------------------------------------------------
--
  Function reset_cache Return Boolean is

  Begin
    -- Bug 5469357 : Called from Project Manager approval.
    -- Keep this up to date.
    g_tc_cache.delete;
    g_tc_bb_ok_cache.delete;

    return true;

  Exception
    When Others then
      return false;

  End reset_cache;

end hxc_time_category_utils_pkg;

/
