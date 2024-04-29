--------------------------------------------------------
--  DDL for Package Body IEX_SCORE_NEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_SCORE_NEW_PVT" AS
/* $Header: iexvscfb.pls 120.21.12010000.9 2010/06/02 11:24:18 barathsr ship $ */


G_PKG_NAME    CONSTANT VARCHAR2(30):= 'IEX_SCORE_NEW_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'iexvscfb.pls';
--G_Debug_Level NUMBER := to_number(nvl(fnd_profile.value('IEX_DEBUG_LEVEL'), '0'));
G_Batch_Size  NUMBER ;
PG_DEBUG NUMBER ;

G_MIN_SCORE         VARCHAR2(100);
G_MAX_SCORE         VARCHAR2(100);
G_RULE              VARCHAR2(20) ;
G_WEIGHT_REQUIRED   VARCHAR2(20) ;

l_del_buff_bridge number; --Added by schekuri for bug#6373998 on 31-Aug-2007
tempResult CLOB;
l_new_line varchar2(1):='
';

/*
|| Overview:   validates any given objectID/Object_type pair
||
|| Parameter:  p_Object_ID PK of object you wish to score
||             p_Object_Type Type of Object you wish to score
||                  Alternatively if you wish to score another TYPE of object
||                  not listed pass the following as well:
||             p_col_name name of colum you wish to select on
||             p_table_name name of table to select from
||
|| Return value:  True =OK; Falso=Error
||
|| Source Tables: IEX_DELINQUENCIES_ALL, IEX_CASES_B_ALL, HZ_PARTIES, AR_PAYMENT_SCHEDULES
||                (these are the "FROM_TABLE" on JTF_OBJECTS_B
|| Target Tables:
||
|| Creation date:       01/14/02 3:25:PM
||
|| Major Modifications: when            who                       what
||                      01/14/02        raverma                 created
*/
function validateObjectID (p_object_id   in number,
                           p_object_type in varchar2,
                           p_col_name    in varchar2,
                           p_table_name  in varchar2) return BOOLEAN

is

l_msg_count number;
l_msg_data varchar2(2000);
l_return_status varchar2(1);
l_col_name varchar2(200) ;
l_table_name varchar2(200) ;

    BEGIN

    l_col_name := p_col_name;
    l_table_name := p_table_name;

    -- get FROM_TABLE AND SELECT_ID from JTF_OBJECTS_B
    if l_col_name is null or l_table_name is null then
        begin
             Execute Immediate
             ' Select Select_ID, From_table ' ||
             ' From jtf_objects_b ' ||
             ' where object_code = :p_object_code'
             into l_col_name, l_table_name
             using p_object_type;
        Exception
             When no_data_found then
                return FALSE;
        end;
    end if;

    -- see if the ID passed is OK on the FROM_TABLE/SELECT_ID
    iex_utilities.validate_any_id(p_col_id        => p_object_id,
                                  p_col_name      => l_col_name,
                                  p_table_name    => l_table_name,
                                  x_msg_count     => l_msg_count,
                                  x_msg_data      => l_msg_data,
                                  x_return_status => l_return_status,
                                  p_init_msg_list =>fnd_api.g_false);

    If l_return_Status = 'S' then
        return TRUE;
    else
        return FALSE;
    end if;

Exception
    when others then
            return false;

END validateObjectID;

/*
|| Overview:  compares whether the score engine being used for this object is of valid type
||
|| Parameter:  p_score_id => scoring engine; p_object_type => type of object you wish to score
||
|| Return value: true=OK; FALSE=error
||
|| Source Tables:  IEX_SCORES
||
|| Target Tables:  NA
||
|| Creation date:  01/14/02 4:47:PM
||
|| Major Modifications: when            who                       what
||                      01/14/02        raverma                 created
*/
function checkObject_Compatibility(p_score_id in number,
                                   p_object_type in varchar2) return BOOLEAN
is
    l_object_type varchar2(25);

begin

   begin
        Execute Immediate
        ' Select jtf_object_code ' ||
        ' From iex_scores ' ||
        ' where score_id = :p_score_id'
        into l_object_type
        using p_score_id;
   Exception
        When no_data_found then
        return FALSE;
   end;

    if l_object_type = p_object_type then
        return TRUE;
    else
        return FALSE;
    end if;

Exception
    when others then
            return false;

end checkObject_Compatibility;

/*
|| Overview:  Validate Score_Engine
||
|| Parameter:  p_score_id is score engine you wish to validate
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| Creation date:       01/14/02 3:08:PM
||
|| Major Modifications: when            who                       what
||                      01/14/02        raverma                 created
*/
PROCEDURE Validate_Score_Engine(p_score_id in number) IS

BEGIN
    NULL;
End Validate_Score_Engine;

--Begin Bug 8933776 30-Nov-2009 barathsr
/*
|| Overview:  format_string-To convert the unsupported strings to XML format
||
|| Parameter:  p_string - the string tat has <,>,<>
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| Creation date:       30-Nov-2009
||
|| Major Modifications: when            who                       what
||                      30-Nov-2009     barathsr                 created
*/
FUNCTION format_string(p_string varchar2) return varchar2 IS

  l_string varchar2(2000);
BEGIN

    l_string := replace(p_string,'&','&'||'amp;');
    l_string := replace(l_string,'<','&'||'lt;');
    l_string := replace(l_string,'>','&'||'gt;');
--    l_string := replace(p_string,'<>','!=');

    RETURN l_string;

END format_string;


/*
|| Overview:  print_clob-To format the xml data and write to o/p file
||
|| Parameter:  lob_loc - the clob that needs to be formatted and written to o/p file
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| Creation date:       30-Nov-2009
||
|| Major Modifications: when            who                       what
||                      30-Nov-2009     barathsr                 created
*/
PROCEDURE PRINT_CLOB (lob_loc                in  clob) IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

   l_api_name                      CONSTANT VARCHAR2(30) := 'PRINT_CLOB';
   l_api_version                   CONSTANT NUMBER := 1.0;
   c_endline                       CONSTANT VARCHAR2 (1) := '
';
   c_endline_len                   CONSTANT NUMBER       := LENGTH (c_endline);
   l_start                         NUMBER          := 1;
   l_end                           NUMBER;
   l_one_line                      VARCHAR2 (7000);
     l_charset	                   VARCHAR2(100);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
BEGIN
   --iex_debug_pub.LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
    FND_FILE.put_line( FND_FILE.LOG,'inside print_clob');

   LOOP
      l_end :=
            DBMS_LOB.INSTR (lob_loc      => lob_loc,
                            pattern      => c_endline,
                            offset       => l_start,
                            nth          => 1
                           );

	--		   FND_FILE.put_line( FND_FILE.LOG,'l_end-->'||l_end);


      IF (NVL (l_end, 0) < 1)
      THEN
         EXIT;
      END IF;

      l_one_line :=
            DBMS_LOB.SUBSTR (lob_loc      => lob_loc,
                             amount       => l_end - l_start,
                             offset       => l_start
                            );
			--    FND_FILE.put_line( FND_FILE.LOG,'l_one_line-->'||l_one_line);
			--   FND_FILE.put_line( FND_FILE.LOG,'c_endline_len-->'||c_endline_len);
      l_start := l_end + c_endline_len;
--      FND_FILE.put_line( FND_FILE.LOG,'l_start-->'||l_start);
--      FND_FILE.put_line( FND_FILE.LOG,'32');
      Fnd_File.PUT_line(Fnd_File.OUTPUT,l_one_line);

   END LOOP;

END PRINT_CLOB;

--End Bug 8933776 30-Nov-2009 barathsr

/*
 * clchang added this new procedure 10/18/04 for 11.5.11.
 * this procedure will get the score_range_low, score_range_high,
 * out_of_range_rule for a given score engine, and update the
 * global variables: G_MIN_SCORE, G_MAX_SCORE, G_RULE.
 *
 * Parameter: P_SCORE_ID   Scoring_Engine
 * Major Modifications:
 *      when            who                       what
 *     10/18/04        clchang                  created
 ******/
 PROCEDURE getScoreRange(P_SCORE_ID       IN NUMBER )
 IS

    CURSOR c_chk_range(p_score_id NUMBER) IS
       SELECT NVL(WEIGHT_REQUIRED, 'N'),
              NVL(SCORE_RANGE_LOW, IEX_SCORE_NEW_PVT.G_MIN_SCORE),
              NVL(SCORE_RANGE_HIGH, IEX_SCORE_NEW_PVT.G_MAX_SCORE),
              NVL(OUT_OF_RANGE_RULE, IEX_SCORE_NEW_PVT.G_RULE)
         FROM IEX_SCORES
        WHERE SCORE_ID = p_score_id;

    l_weight_required     VARCHAR2(3);
    l_low                 varchar2(2000);
    l_high                varchar2(2000);
    l_rule                varchar2(20);

 BEGIN

    -- chk the score range
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScoreRange: score_id=' || p_score_id);
    END IF;

    BEGIN
        OPEN c_chk_range(p_score_id);
       FETCH c_chk_range
        INTO l_weight_required, l_low, l_high, l_rule;
       CLOSE c_chk_range;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScoreRange: Error getting score range: ' || sqlerrm);
           END IF;
           l_weight_required := IEX_SCORE_NEW_PVT.G_WEIGHT_REQUIRED;
           l_low := IEX_SCORE_NEW_PVT.G_MIN_SCORE;
           l_high := IEX_SCORE_NEW_PVT.G_MAX_SCORE;
           l_rule := IEX_SCORE_NEW_PVT.G_RULE;
       WHEN OTHERS THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScoreRange: Error getting scr range: ' || sqlerrm);
           END IF;
           l_weight_required := IEX_SCORE_NEW_PVT.G_WEIGHT_REQUIRED;
           l_low := IEX_SCORE_NEW_PVT.G_MIN_SCORE;
           l_high := IEX_SCORE_NEW_PVT.G_MAX_SCORE;
           l_rule := IEX_SCORE_NEW_PVT.G_RULE;
    END;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScoreRange: weight:' || l_weight_required);
        IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScoreRange: low:' || l_low);
        IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScoreRange: high:' || l_high);
        IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScoreRange: rule:' || l_rule);
    END IF;

    IEX_SCORE_NEW_PVT.G_WEIGHT_REQUIRED := l_weight_required;
    IEX_SCORE_NEW_PVT.G_MIN_SCORE := l_low;
    IEX_SCORE_NEW_PVT.G_MAX_SCORE := l_high;
    IEX_SCORE_NEW_PVT.G_RULE := l_rule;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScoreRange: g_weight:' || IEX_SCORE_NEW_PVT.G_WEIGHT_REQUIRED);
        IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScoreRange: g_low:' || IEX_SCORE_NEW_PVT.G_MIN_SCORE);
        IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScoreRange: g_high:' || IEX_SCORE_NEW_PVT.G_MAX_SCORE);
        IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScoreRange: g_rule:' || IEX_SCORE_NEW_PVT.G_RULE);
    END IF;

 END getScoreRange;




/*
|| this procedure will get all components for a given score engine
||  and return them as a tbl
||
|| Parameter: P_SCORE_ID   Scoring_Engine
||            X_SCORE_COMP_TBL = table of components attached to the Scoring engine
||
|| Return value: select statement for the Universe
||
|| Source Tables: IEX_SCORES, IEX_SCORE_COMPONENTS, IEX_SCORE_COMP_TYPES_B/TL
||
|| Target Tables: none
||
|| Creation date:  01/14/02 1:55:PM
||
|| Major Modifications: when            who                       what
||                      01/14/02        raverma             created
||                      03/12/02        raverma             added function_flag to return tbl
||   10/18/04        clchang      updated this procedure for scoring engine enhancement
||                                in 11.5.11.
||                                1. new column METRIC_FLAG in iex_score_components
*/
PROCEDURE getComponents(P_SCORE_ID       IN NUMBER,
                        X_SCORE_COMP_TBL OUT NOCOPY IEX_SCORE_NEW_PVT.SCORE_ENG_COMP_TBL)
IS

    -- clchang updated the cursor 10/18/04 with metric_flag;
    --
    -- this cursor will enumerate all components for a particular engine
    CURSOR c_score_components(p_score_id NUMBER) IS
        SELECT
            SCORE_COMPONENT_ID,
            SCORE_COMP_WEIGHT,
            SCORE_COMP_VALUE,
            NVL(FUNCTION_FLAG, 'N') FUNCTION_FLAG
        FROM
            IEX_SCORE_ENG_COMPONENTS_V
        WHERE SCORE_ID = p_score_id
          AND NVL(METRIC_FLAG, 'N') = 'N'
	  order by score_component_id;


     l_score_comp_tbl IEX_SCORE_NEW_PVT.SCORE_ENG_COMP_TBL;
     i                        NUMBER := 0;
     l_score_comp_id          NUMBER;
     l_score_component_weight NUMBER(3,2);
     l_score_comp_value       VARCHAR2(2000);
     l_function_flag          VARCHAR2(1);

Begin

--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.logMessage('IEX_SCORE: getComponents: getting Score Engine Components for Engine: ' || p_score_id);
        END IF;

        OPEN c_score_components(p_score_id);
        LOOP
            i := i + 1;
        FETCH c_score_components INTO
            l_score_comp_id, l_score_component_weight, l_score_comp_value, l_function_flag;
        EXIT WHEN c_score_components%NOTFOUND;
            l_score_comp_tbl(i).SCORE_COMPONENT_ID := l_score_comp_id;
            l_score_comp_tbl(i).SCORE_COMP_WEIGHT  := l_score_component_weight;
            l_score_comp_tbl(i).SCORE_COMP_VALUE   := l_score_comp_value;
            l_score_comp_tbl(i).FUNCTION_FLAG      := l_function_flag;
	    --- Begin - Andre Araujo - 11/02/2004 - New storage mode, Scores_tbl becomes too big - TAR 4040621.994
            l_score_comp_tbl(i).SCORE_ID           := p_score_id;
	    --- End - Andre Araujo - 11/02/2004 - New storage mode, Scores_tbl becomes too big - TAR 4040621.994
        END LOOP;

--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.logMessage('IEX_SCORE: getComponents: components found ' || l_score_comp_tbl.count);
        END IF;
        x_score_comp_tbl := l_score_comp_tbl;

        CLOSE c_score_components;

        Exception
            When No_Data_Found then
                x_score_comp_tbl := l_score_comp_tbl;
                CLOSE c_score_components;

            When others Then
                x_score_comp_tbl := l_score_comp_tbl;
                CLOSE c_score_components;

end getComponents;

/*
|| Overview:   This is the "main" scoring function.  It will score any objects using the
||             table of components passed to.  The assumption is that any validation has been done already AND
||             the table of components passed here is appropriate for the universe of IDS
||
|| Parameter:  p_score_comp_tbl => components to use for scoring execution
||             t_object_ids     => universe of object_ids you wish to score
||                  (this universe MUST be valid for the components definition)
||             x_scores_tbl     => table of scores for the IDs passed
||
||   11/02/04        acaraujo     x_scores_tbl returns the bridge to the next concurrent prog.
|| 				  and scores are store as per the G_BATCH_SIZE to the history table
||
|| Source Tables: iex_score_comp_det
||
|| Target Tables: NA
||
|| Creation date:       01/14/02 5:27:PM
||
|| Major Modifications: when            who                       what
||                      01/14/02        raverma                 created
||   10/18/04        clchang      updated this procedure for scoring engine enhancement
||                                in 11.5.11.
||                                1. new column METRIC_FLAG in iex_score_components
||                                2. new columns 'WEIGHT_REQUIRED, SCORE_RANGE_LOW,
||                                   SCORE_RANGE_HIGH, OUT_OF_RANGE_RULE' in iex_scores
||                                3. no 1-100 score limitation;
||                                4. weight_required decides the weight of comp;
||                                5. in comp det, the value could be formula;
||                                   (only one BIND Var :result could be used.)
||
||   11/02/04        acaraujo     x_scores_tbl returns the bridge to the next concurrent prog.
|| 				  and scores are store as per the G_BATCH_SIZE to the history table
*/
procedure getScores(p_score_comp_tbl IN IEX_SCORE_NEW_PVT.SCORE_ENG_COMP_TBL,
                    t_object_ids     IN IEX_FILTER_PUB.UNIVERSE_IDS,
                    x_scores_tbl     OUT NOCOPY IEX_SCORE_NEW_PVT.SCORES_TBL)
IS

    l_api_name            varchar2(10) ;
    l_universe_size       number := 0;
    l_count               NUMBER := 0;
    l_components_count    number := 0;

    l_weight_required     VARCHAR2(3);
    l_low                 varchar2(2000);
    l_high                varchar2(2000);
    l_rule                varchar2(20);
    --l_raw_score           number := IEX_SCORE_NEW_PVT.G_MIN_SCORE;
    l_raw_score           number := 0;
    l_value               VARCHAR2(2000);
    l_new_value           VARCHAR2(2000);

    l_running_score       number := 0;
    l_component_score     number := 0;
    l_count2              number := 0;
    l_score_comp_tbl      IEX_SCORE_NEW_PVT.SCORE_ENG_COMP_TBL ;
    l_score_component_id  NUMBER;
    l_score_component_sql VARCHAR2(2500);
    l_scores_tbl          IEX_SCORE_NEW_PVT.SCORES_TBL;
    vSql                  varchar2(2500);

    type COMPONENT_RANGE is table of NUMBER
        index by binary_integer;
    l_component_range_tbl COMPONENT_RANGE;
    i                     NUMBER := 0;
    l_execute_style       VARCHAR2(1);  -- are we using select or function call

--- Begin - Andre Araujo - 11/02/2004 - New storage mode, this one respects the commit size - TAR 4040621.994
    l_new_scores_tbl      IEX_SCORE_NEW_PVT.NEW_SCORES_TBL ;
    l_objects_tbl         IEX_SCORE_NEW_PVT.SCORE_OBJECTS_TBL ;
    l_scorecount          number := 0;
    l_bridge              NUMBER;
--- End - Andre Araujo - 11/02/2004 - New storage mode, this one respects the commit size - TAR 4040621.994

    -- Begin - Andre Araujo - 12/17/2004 - Store del_buffers only if we need to
    l_conc_prog_name    VARCHAR2(1000);
    -- End - Andre Araujo - 12/17/2004 - Store del_buffers only if we need to
   --Begin Bug 8933776 30-Nov-2009 barathsr
    l_xml_body_2 varchar2(1000);
    l_jtf_obj_code varchar2(100);
    l_object_id number;
 --   l_party_name varchar(360);
    l_object_name varchar2(360);
    l_acct_number varchar2(100);
    --End Bug 8933776 30-Nov-2009 barathsr

BEGIN

    l_api_name := 'getScores';
    l_score_comp_tbl      := p_score_comp_tbl;

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: Start time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;
    --
    -- Api body
    --
    --- Begin - Andre Araujo - 11/02/2004 - New storage mode, this one respects the commit size - TAR 4040621.994
    --Commented by schekuri for bug#6373998 by schekuri on 31-Aug-2007
    --Select IEX_DEL_WF_S.NEXTVAL INTO l_bridge FROM Dual;
    --- End - Andre Araujo - 11/02/2004 - New storage mode, this one respects the commit size - TAR 4040621.994

    l_bridge := l_del_buff_bridge; --Added by schekuri for bug#6373998 by schekuri on 31-Aug-2007
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Using bridge id ' || l_bridge);
    l_universe_size := t_object_ids.count;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: Universe size is ' || l_universe_size);
    END IF;

    -- Begin - Andre Araujo - 12/17/2004 - Store del_buffers only if we need to
    Begin -- This will be an exception block
    Select NVL(CONCURRENT_PROG_NAME, 'X')
    Into l_conc_prog_name
    From IEX_SCORES scr, IEX_SCORE_COMPONENTS scomp
    Where scomp.score_component_id = p_score_comp_tbl(1).SCORE_COMPONENT_ID
      AND scr.Score_ID = scomp.score_id;
    exception
       when OTHERS THEN
            l_conc_prog_name := 'X';
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'IEX_SCORE: getScores: Exception getting the concurrent program. Error: ' || sqlerrm );
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'IEX_SCORE: getScores: Program will continue, no concurrent program will be launched' );
    end;
    -- End - Andre Araujo - 12/17/2004 - Store del_buffers only if we need to

    FOR l_count IN 1..l_universe_size LOOP

            if PG_DEBUG <= 5 then
                   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: Scoring item ' || l_count || ' in universe');
                   END IF;
            end if;
            l_components_count := p_score_comp_tbl.count;
            l_running_score := 0;
	  --  fnd_file.put_line(fnd_file.log,'universe size-->'||l_universe_size);

	 --   l_xml_body_2:=l_new_line||'<COMP_DET>'||l_new_line;
	--    dbms_lob.writeAppend(tempResult, length(l_xml_body_2), l_xml_body_2);

	--Begin Bug 8933776 30-Nov-2009 barathsr
	begin
		  select score.jtf_object_code
		  into l_jtf_obj_code
		  from iex_scores score
		  where score_id=p_score_comp_tbl(1).score_id;
	--	  fnd_file.put_line(fnd_file.log,'obj_code-->'||l_jtf_obj_code);
            --        fnd_file.put_line(fnd_file.log,'unv_id-->'||t_object_ids(l_count));

		  if l_jtf_obj_code is not null then
		    if l_jtf_obj_code='PARTY' then
		       select party_name
		       into l_object_name
		       from hz_parties
		       where party_id=t_object_ids(l_count);
		       l_object_id:=t_object_ids(l_count);
		     elsif l_jtf_obj_code='IEX_ACCOUNT' then
		       select account_number
		       into l_object_name
		       from hz_cust_accounts
		       where cust_account_id=t_object_ids(l_count);
		       l_object_id:=t_object_ids(l_count);
		     elsif l_jtf_obj_code='IEX_BILLTO' then
		       select hcsua.location,hca.account_number
		       into l_object_name,l_acct_number
		       from hz_cust_site_uses_all hcsua,hz_cust_acct_sites_all hcasa, hz_cust_accounts hca
		       where hcsua.cust_acct_site_id=hcasa.cust_acct_site_id
		       and hcasa.cust_account_id=hca.cust_account_id
		       and hcsua.site_use_code='BILL_TO'
		       and hcsua.site_use_id=t_object_ids(l_count);
		       l_object_id:=t_object_ids(l_count);
		     elsif l_jtf_obj_code='IEX_INVOICES' then
		       select aps.trx_number,hca.account_number
		       into l_object_name,l_acct_number
		       from ar_payment_schedules_all aps,hz_cust_accounts hca
		       where aps.customer_id=hca.cust_account_id
		       and aps.payment_schedule_id=t_object_ids(l_count)
		       and aps.payment_schedule_id>0;
		       l_object_id:=t_object_ids(l_count);
		     end if;
		   end if;
              --      FND_FILE.put_line( FND_FILE.LOG,'*****get various score details************');
	          l_xml_body_2:=l_new_line||'<COMP_DET>';
	        --  l_xml_body_2:=l_xml_body_2||l_new_line||'<PARTY_NAME>'||format_string(l_obj_name)||'</PARTY_NAME>';
                  l_xml_body_2:=l_xml_body_2||l_new_line||'<OBJECT_NAME>'||format_string(l_object_name)||'</OBJECT_NAME>';
		  l_xml_body_2:=l_xml_body_2||l_new_line||'<ACCT_NUMBER>'||format_string(l_acct_number)||'</ACCT_NUMBER>';
		  l_xml_body_2:=l_xml_body_2||l_new_line||'<OBJECT_ID>'||l_object_id||'</OBJECT_ID>';
		   l_xml_body_2:=l_xml_body_2||l_new_line||'<COMP_VALUES>';
                 dbms_lob.writeAppend(tempResult, length(l_xml_body_2), l_xml_body_2);
	  exception
	   when others then
	    FND_FILE.PUT_LINE(FND_FILE.LOG, 'error in get scores in getting jtf obj details'||sqlerrm);
            IEX_DEBUG_PUB.logMessage('error in get scores in getting jtf obj details'||sqlerrm);
         end;
	--End Bug 8933776 30-Nov-2009 barathsr
      --    fnd_file.put_line(fnd_file.log,'callin get1score');

--- get1Score removed from here
	    l_running_score := get1Score( l_score_comp_tbl, t_object_ids(l_count) );
	--    fnd_file.put_line(fnd_file.log,'out of get1score');
--- End get1Score removed from here
--          /* 3. for each component, execute SQL and get value */
--          FOR l_count2 IN 1..l_components_count LOOP
--              l_score_component_id  := l_score_comp_tbl(l_count2).score_component_id;
--              l_score_component_sql := l_score_comp_tbl(l_count2).SCORE_COMP_VALUE;
--              l_execute_style       := l_score_comp_tbl(l_count2).function_flag;
--              -- initialize this to the minimum for any given component
--              --l_raw_score := IEX_SCORE_PVT.G_MIN_SCORE;
--
--              if PG_DEBUG <= 5 then
--                     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
--                     IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: executing Component ' || l_count2 || ' CompID is: ' || l_score_component_id);
--                     IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: Execute Stmt: ' || l_score_component_sql || ' Execute Style: ' || l_execute_style);
--                     IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: Bind Variable: ' || t_object_ids(l_count));
--                     END IF;
--              end if;
--
--              /* executing dynamic sql for component */
--              if l_score_component_sql is not null then
--                  BEGIN
--
--                   -- Execute SQL statement only when function syntax is not found
--                   if l_execute_style = 'N' then
--                      -- simple select statement
--                      EXECUTE IMMEDIATE l_score_component_sql
--                              INTO l_component_score
--                              USING t_object_ids(l_count);
--                   else
--                      -- function to execute
--                      -- to do - pass the score component id for Function calls only
--                      EXECUTE IMMEDIATE l_score_component_sql
--                                 USING in t_object_ids(l_count),
--                                       in l_score_component_id,
--                                       out l_component_score;
--                   end if;
--
--                  EXCEPTION
--
--                      -- assign the "Lowest" Detail for the component
--                      -- in order to do this we must know what is "high" and "low" range of component
--
--                      WHEN OTHERS THEN
--                          -- figure out whether the component details are better higher or worse higher
--                            IF PG_DEBUG <= 5  THEN
--                          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
--                             IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: Failed to calculate for component ' || l_score_component_id );
--                          END IF;
--                          SELECT Range_Low
--                          BULK COLLECT INTO l_component_range_tbl
--                            FROM iex_score_comp_det
--                           where score_component_id = l_score_component_id
--                          order by value;
--
--                          if l_component_range_tbl(1) < l_component_range_tbl(2) then
--                              -- assign first comnponent detail row range to value
--                              l_component_score := l_component_range_tbl(1);
--                          else
--                              -- assign last comnponent detail row range to value
--                              i := l_component_range_tbl.count;
--                              l_component_score := l_component_range_tbl(i);
--                          end if;
--
--                  END;
--
--                if PG_DEBUG <= 5 then
--                      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
--                      IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: Successfully calculated component score: ' || l_component_score);
--                      END IF;
--                end if;
--
--              end if;
--
--          /* 4. For each component value, get the details of the component
--          and store the value for that score_comp_detail */
--           BEGIN
--              -- clchang updated 10/18/04 for 11.5.11
--              -- new column NEW_VALUE instead of VALUE in iex_score_comp_det;
--              --vSql := 'SELECT VALUE ' ||
--              vSql := 'SELECT upper(NEW_VALUE) ' ||
--                      '  FROM IEX_SCORE_COMP_DET ' ||
--                      ' WHERE SCORE_COMPONENT_ID = :p_score_comp_id AND ' ||
--                      '       :p_component_score >= RANGE_LOW AND ' ||
--                      '       :p_component_score <= RANGE_HIGH  ';
--              if PG_DEBUG <= 5 then
--                     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
--                     IEX_DEBUG_PUB.logMessage('getScores: ' || 'Getting Details for component with ' || vSQL);
--                     END IF;
--              end if;
--
--              -- clchang updated 10/18/04 for 11.5.11
--              -- the value from det could be formula (including bind var :result);
--              Execute Immediate vSql
--                  --INTO l_raw_score
--                  INTO l_value
--                  USING l_score_component_id, l_component_score, l_component_score;
--
--              --IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
--              --IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: Component raw score is ' || l_raw_score || ' Component weight is ' || l_score_comp_tbl(l_count2).SCORE_COMP_WEIGHT);
--              --END IF;
--
--
--              -- BEGIN clchang added 10/18/04 for scr engine enhancement in 11.5.11
--
--              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
--                  IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: l_value=' || l_value);
--              END IF;
--              -- chk the value is a formula or not
--              IF (INSTR(l_value, ':RESULT') > 0 ) THEN
--                l_new_value := replace(l_value, ':RESULT', l_component_score);
--                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
--                  IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: FORMULA');
--                  IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: l_new_value=' || l_new_value);
--                END IF;
--                vSql := 'SELECT ' || l_new_value || ' FROM DUAL';
--                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
--                  IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: vSql=' || vSql);
--                END IF;
--                Execute Immediate vSql
--                   INTO l_raw_score;
--              ELSE
--                l_raw_score := TO_NUMBER( l_value);
--              END IF;
--              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
--                IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: l_raw_score=' || l_raw_score);
--              END IF;
--
--
--              l_weight_required := IEX_SCORE_NEW_PVT.G_WEIGHT_REQUIRED;
--
--              -- if weight_required <> Y, sum(score of each comp);
--              IF (l_weight_required = 'Y') THEN
--                  --l_running_score:=l_running_score + round((l_raw_score * l_score_comp_tbl(l_count2).SCORE_COMP_WEIGHT));
--                  l_running_score:=l_running_score + round((l_raw_score * l_score_comp_tbl(l_count2).SCORE_COMP_WEIGHT),2);
--              ELSE
--                  --l_running_score:=l_running_score + round(l_raw_score );
--                  l_running_score:=l_running_score + round(l_raw_score,2 );
--              END IF;
--              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
--                IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: l_running_score=' || l_running_score);
--              END IF;
--              -- END clchang added 10/18/04 for scr engine enhancement in 11.5.11
--
--             /*
--              l_running_score:=l_running_score + round((l_raw_score * l_score_comp_tbl(l_count2).SCORE_COMP_WEIGHT));
--              */
--
--              --IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
--              --IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: Component Running score is ' || l_running_score);
--              --END IF;
--           EXCEPTION
--                  WHEN NO_DATA_FOUND THEN
--                        IF PG_DEBUG < 10  THEN
--                      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
--                         IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: Error getting component detail: ' || sqlerrm);
--                      END IF;
--                      l_running_score := l_running_score;
--                  WHEN OTHERS THEN
--                        IF PG_DEBUG < 10  THEN
--                      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
--                         IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: Error getting component detail: ' || sqlerrm);
--                      END IF;
--                      l_running_score := l_running_score;
--           END;
--
--          END LOOP; -- component loop
--
--
--          -- BEGIN clchang added 10/18/04 for scr engine enhancement in 11.5.11
--
          -- clchang updated the score logic
          /***************
          -- if the score value falls above or below the hard coded floor / ceiling we will force the score
          -- to the floor or ceiling
          if l_running_score <  IEX_SCORE_NEW_PVT.G_MIN_SCORE then
              l_running_score := IEX_SCORE_NEW_PVT.G_MIN_SCORE;
          elsif l_running_score > IEX_SCORE_NEW_PVT.G_MAX_SCORE then
              l_running_score := IEX_SCORE_NEW_PVT.G_MAX_SCORE;
          end if;
          *******************************************/

          /*********************
           * with the new logic on scr engine;
           * 1.no score limitation 1-100;
           * 2.the score range should between score_range_low and score_range_high of
           *   each scoring engine;
           * 3. if the score is out of range, following the out_of_range_rule of
           *    each scoring engine;
           *    ex: one scoring engine with low -50, high 999 and rule 'CLOSEST';
           *        if the score is -100, then the final score should be the closest
           *        score of score range => -50;
           *        if the rule is farthest, then the final score should be 999;
           ***********************************************************************/

           -- get the final score
           l_rule := IEX_SCORE_NEW_PVT.G_RULE;
           IF (l_rule = 'CLOSEST') THEN
              if l_running_score <  IEX_SCORE_NEW_PVT.G_MIN_SCORE then
                 l_running_score := IEX_SCORE_NEW_PVT.G_MIN_SCORE;
              elsif l_running_score > IEX_SCORE_NEW_PVT.G_MAX_SCORE then
                 l_running_score := IEX_SCORE_NEW_PVT.G_MAX_SCORE;
              end if;
           ELSE
              if l_running_score <  IEX_SCORE_NEW_PVT.G_MIN_SCORE then
                 l_running_score := IEX_SCORE_NEW_PVT.G_MAX_SCORE;
              elsif l_running_score > IEX_SCORE_NEW_PVT.G_MAX_SCORE then
                 l_running_score := IEX_SCORE_NEW_PVT.G_MIN_SCORE;
              end if;
           END IF;
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: score:' || l_running_score);
           END IF;
          -- END clchang added 10/18/04 for scr engine enhancement in 11.5.11
	  --Begin Bug 8933776 30-Nov-2009 barathsr
          l_xml_body_2:=l_new_line||'</COMP_VALUES>';
	  l_xml_body_2:=l_xml_body_2||l_new_line||'<FINAL_SCORE>'||l_running_score||'</FINAL_SCORE>';
	  l_xml_body_2:=l_xml_body_2||l_new_line||'</COMP_DET>';

	  dbms_lob.writeAppend(tempResult, length(l_xml_body_2), l_xml_body_2);
          --End Bug 8933776 30-Nov-2009 barathsr

	 -- fnd_file.put_line(fnd_file.log,'end of comp_det tag');


    -- fill out return table
	--- Begin - Andre Araujo - 11/02/2004 - New storage mode, this one respects the commit size - TAR 4040621.994
        --l_scores_tbl(l_count) := l_running_score;

	l_scorecount := l_scorecount + 1;
	l_objects_tbl(l_scorecount)    :=  t_object_ids(l_count);
	l_new_scores_tbl(l_scorecount) :=  l_running_score;
	if l_scorecount >= G_BATCH_SIZE then

		storeScoreHistory ( l_score_comp_tbl(1).SCORE_ID, l_objects_tbl, l_new_scores_tbl );
                -- Begin - Andre Araujo - 12/17/2004 - Store del_buffers only if we need to
                if (l_conc_prog_name <> 'X') then
			storeDelBuffers ( l_score_comp_tbl(1).SCORE_ID, l_objects_tbl, l_new_scores_tbl,l_bridge);
		end if;
                -- End - Andre Araujo - 12/17/2004 - Store del_buffers only if we need to


		l_scorecount := 0;
		l_objects_tbl.delete;
		l_new_scores_tbl.delete;
		l_scores_tbl.delete;
	end if;
	--- End - Andre Araujo - 11/02/2004 - New storage mode, this one respects the commit size - TAR 4040621.994



    END LOOP; -- universe loop

 --   fnd_file.put_line(fnd_file.log,'out of universe loop in get scores');

         --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Getting the final score: ');
		--l_xml_body_2:=l_xml_body_2||l_new_line||'</COMP_DET>'||l_new_line;

	--	dbms_lob.writeAppend(tempResult, length(l_xml_body_2), l_xml_body_2);
	--	 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Closing comp_det ');

    --- Begin - Andre Araujo - 11/02/2004 - New storage mode, this one respects the commit size - TAR 4040621.994
    if l_scorecount > 0 then -- Store the leftovers
  	storeScoreHistory ( l_score_comp_tbl(1).SCORE_ID, l_objects_tbl, l_new_scores_tbl );
	-- Begin - Andre Araujo - 12/17/2004 - Store del_buffers only if we need to
	if (l_conc_prog_name <> 'X') then
		storeDelBuffers ( l_score_comp_tbl(1).SCORE_ID, l_objects_tbl, l_new_scores_tbl,l_bridge);
	end if;
	-- End - Andre Araujo - 12/17/2004 - Store del_buffers only if we need to


    end if;

  --  fnd_file.put_line(fnd_file.log,'end of get scores');

    l_scores_tbl.delete;
    l_scores_tbl(1) := l_bridge;
    --- End - Andre Araujo - 11/02/2004 - New storage mode, this one respects the commit size - TAR 4040621.994

    x_scores_tbl := l_scores_tbl;

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;

Exception

    When Others Then
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in getScores: ' || sqlerrm );
        RAISE FND_API.G_EXC_ERROR;
END getScores;

/*
|| Overview:    score all objects for a given scoring engine
||
|| Parameter:   p_score_id => scoring engine ID
||
|| Source Tables:   IEX_SCORES, IEX_SCORE_COMPONENTS_VL, IEX_SCORE_COMP_TYPES, IEX_SCORE_COMP_DET,
||                  IEX_OBJECT_FILTERS
||
|| Target Tables:
||
|| Creation date:       01/22/02 3:14:PM
||
|| Major Modifications: when            who                       what
||                      01/22/02        raverma             created
*/
procedure scoreObjects(p_api_version    IN NUMBER,
                       p_init_msg_list  IN VARCHAR2,
                       p_commit         IN VARCHAR2,
                       P_SCORE_ID       IN NUMBER,
		       p_unv_obj_id in varchar2, --Added for Bug 8933776 17-Dec-2009 barathsr
		       p_limit_rows_val in number default null, --Added for Bug 8933776 17-Dec-2009 barathsr
                       x_return_status  OUT NOCOPY VARCHAR2,
                       x_msg_count      OUT NOCOPY NUMBER,
                       x_msg_data       OUT NOCOPY VARCHAR2)
IS

    l_api_name           varchar2(25);
    l_api_version_number number := 1;
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(32767);

    --vPLSQL           varchar2(5000);
    l_universe          IEX_FILTER_PUB.UNIVERSE_IDS;     -- for TestUniverse / testGetScores
    l_components_tbl    IEX_SCORE_NEW_PVT.SCORE_ENG_COMP_TBL;-- for testGetComponents / testGetScores
    l_scores_tbl        IEX_SCORE_NEW_PVT.SCORES_TBL;  -- fore testGetScores
    b_valid             BOOLEAN;
   -- l_object_type       VARCHAR2(25);
    l_universe_size     NUMBER := 0;
    l_conc_prog_name    VARCHAR2(1000);
    l_submit_request_id NUMBER;
    l_bridge            NUMBER;
    k                   NUMBER := 1;
    l_passes            NUMBER := 0;
    l_mod               NUMBER := 0;
    l_user              NUMBER;
    i                   NUMBER := 1;
    l_program           NUMBER;
    l_prog_appl         NUMBER;
    l_request           NUMBER;
    --Begin Bug 8933776 30-Nov-2009 barathsr
    l_xml_body  varchar2(11000);
   -- l_new_line varchar2(1);
    l_score_name varchar2(100);
    l_object_code varchar2(100);
    l_object_type varchar2(100);
    l_obj_filter_name varchar2(100);
    l_obj_filter_view varchar2(100);
    l_cp_name varchar2(100);
    l_sts_det varchar2(10);
    l_score_low number;
    l_score_high number;
    l_score_comp_name varchar2(100);
    l_function_flg varchar2(10);
    l_score_comp_wgt number;
    l_score_comp_id number;
    l_sc_range_low IEX_SCORE_NEW_PVT.SCORES_TBL;
    l_sc_range_high IEX_SCORE_NEW_PVT.SCORES_TBL;
    l_sc_val IEX_SCORE_NEW_PVT.SCORES_TBL;
    l_cnt number;
    l_score_comp_val varchar2(5000);
    --End Bug 8933776 30-Nov-2009 barathsr

   --jsanju 06/21/04 --added for wait for request check
    uphase VARCHAR2(255);
    dphase VARCHAR2(255);
    ustatus VARCHAR2(255);
    dstatus VARCHAR2(255);
    l_bool BOOLEAN;
    message VARCHAR2(32000);
    l_last_obj_scored   NUMBER;
    l_last_batch        boolean;


   -- Begin - schekuri - 6156648 - 10/Jun/2007 - Adding wait for request to try to make it wait
    bReturn boolean;
    vReturn varchar2(100);
    -- End - schekuri - 6156648 - 10/Jun/2007 - Adding wait for request to try to make it wait

    -- start for bug 9387044
     vsql varchar2(1000);
     l_count number;
     l_return boolean;
     univ_size number;
     Type refCur is Ref Cursor;
     Universe_cur refCur;
    -- end for bug 9387044

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT scoreObjects_PVT;

      l_api_name         := 'scoreObjects';

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version_number, p_api_version,
                                          l_api_name, G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreObjects: Start time:'|| TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      /*select score_name
      into l_score_name
      from iex_scores
      where score_id=p_score_id;
      --
      -- Api body
      --

      -- initial variables needed
      select jtf_object_code into l_object_type
      from iex_scores
      where score_id = p_score_id;*/
      --Begin Bug 8933776 30-Nov-2009 barathsr
      begin
      SELECT score.score_name,
	  score.jtf_object_code,
	  obj.object_filter_name,
	  obj.entity_name,
	  score.concurrent_prog_name,
	  score.status_determination,
	  score.score_range_low,
	  score.score_range_high
	  into l_score_name,l_object_code,l_obj_filter_name,l_obj_filter_view,l_cp_name,l_sts_det,l_score_low,l_score_high
	FROM iex_scores score,
	  iex_object_filters obj
	WHERE score.score_id        =obj.object_id
	AND obj.object_filter_type='IEXSCORE'
	and score.score_id=p_score_id;

     SELECT NAME
     into l_object_type
     FROM jtf_objects_vl
     where object_code=l_object_code;

    --  FND_FILE.PUT_LINE(FND_FILE.LOG, '***start of xml body***');
      l_xml_body:= l_xml_body||l_new_line||'<SCOREDET>';
      l_xml_body:= l_xml_body||l_new_line||'<SCORE_ID>'||p_score_id||'</SCORE_ID>';
      l_xml_body:= l_xml_body||l_new_line||'<SCORE_NAME>'||format_string(l_score_name)||'</SCORE_NAME>';
      l_xml_body:= l_xml_body||l_new_line||'<OBJ_CODE>'||format_string(l_object_code)||'</OBJ_CODE>';
      l_xml_body:= l_xml_body||l_new_line||'<OBJ_TYPE>'||format_string(l_object_type)||'</OBJ_TYPE>';
      l_xml_body:= l_xml_body||l_new_line||'<FILTER_NAME>'||format_string(l_obj_filter_name)||'</FILTER_NAME>';
      l_xml_body:= l_xml_body||l_new_line||'<FILTER_VIEW>'||format_string(l_obj_filter_view)||'</FILTER_VIEW>';
      l_xml_body:= l_xml_body||l_new_line||'<PROGRAM_NAME>'||format_string(l_cp_name)||'</PROGRAM_NAME>';
      l_xml_body:= l_xml_body||l_new_line||'<STATUS_DET>'||l_sts_det||'</STATUS_DET>';
      l_xml_body:= l_xml_body||l_new_line||'<SCORE_LOW>'||l_score_low||'</SCORE_LOW>';
      l_xml_body:= l_xml_body||l_new_line||'<SCORE_HIGH>'||l_score_high||'</SCORE_HIGH>';
      l_xml_body:= l_xml_body||l_new_line||'<COMPONENTS>';
      exception
        when others then
	  FND_FILE.PUT_LINE(FND_FILE.LOG, 'error in score objects in getting score details'||sqlerrm);
           IEX_DEBUG_PUB.logMessage('error in score objects in getting score details'||sqlerrm);
      end;
      --End Bug 8933776 30-Nov-2009 barathsr
      -- enumerate components for this scoring engine
      iex_score_new_pvt.getComponents(p_score_id       => p_score_id ,
                                      X_SCORE_COMP_TBL => l_components_tbl);

      if l_components_tbl is null or l_components_tbl.count < 1 then
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreObjects: No score components for engine');
          END IF;
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'IEX_SCORE: scoreObjects: No score components for engine ' || p_score_id);
          FND_MESSAGE.Set_Name('IEX', 'IEX_NO_SCORE_ENG_COMPONENTS');
	  --Begin Bug 8933776 30-Nov-2009 barathsr
          l_xml_body:= l_xml_body||l_new_line||'<ERROR>'||'No Score components available for this scoring engine'||'</ERROR>';
	  l_xml_body:= l_xml_body||l_new_line||'</COMPONENTS>';
	  l_xml_body:= l_xml_body||l_new_line||'</SCOREDET>';
         -- l_xml_body:= l_xml_body||l_new_line||'</SCORE_REPORT>';
	  dbms_lob.writeAppend(tempResult, length(l_xml_body), l_xml_body);
	  --End Bug 8933776 30-Nov-2009 barathsr
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
      end if;

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.logMessage('scoreObjects: ' || 'Batch Size is ' || G_BATCH_SIZE || ' rows');
      END IF;

      l_user      := FND_GLOBAL.USER_ID;
      l_request   := nvl(FND_GLOBAL.Conc_REQUEST_ID,0);
      l_program   := FND_GLOBAL.CONC_PROGRAM_ID;
      l_prog_appl := FND_GLOBAL.PROG_APPL_ID;

      --Begin Bug 8933776 30-Nov-2009 barathsr
      if l_components_tbl is not null or l_components_tbl.count>1 then
     -- FND_FILE.PUT_LINE(FND_FILE.LOG,'count in comp tab-->'||l_components_tbl.count);
        for comp in l_components_tbl.first..l_components_tbl.last loop
	  begin
	  SELECT sc_typ_tl.score_comp_name,
		  sc_typ.function_flag,
		  sc.score_comp_weight,
		  sc_typ.score_comp_value
		  into l_score_comp_name,l_function_flg,l_score_comp_wgt,l_score_comp_val
		FROM iex_score_components sc,
		  iex_score_comp_types_tl sc_typ_tl,
		  iex_score_comp_types_b sc_typ
		WHERE sc.score_comp_type_id  = sc_typ.score_comp_type_id
		AND sc_typ.score_comp_type_id= sc_typ_tl.score_comp_type_id
		AND sc_typ_tl.language       ='US'
		AND sc.score_component_id=l_components_tbl(comp).score_component_id;
		l_score_comp_id:=l_components_tbl(comp).score_component_id;
		--	 FND_FILE.PUT_LINE(FND_FILE.LOG, '***get the component details***');
          l_xml_body:= l_xml_body||l_new_line||'<COMPONENT>';
          l_xml_body:= l_xml_body||l_new_line||'<SC_COMP_ID>'||l_score_comp_id||'</SC_COMP_ID>';
	  l_xml_body:= l_xml_body||l_new_line||'<COMP_NAME>'||format_string(l_score_comp_name)||'</COMP_NAME>';
          l_xml_body:= l_xml_body||l_new_line||'<FUNCTION_FLAG>'||l_function_flg||'</FUNCTION_FLAG>';
	  l_xml_body:= l_xml_body||l_new_line||'<COMP_WEIGHT>'||l_score_comp_wgt||'</COMP_WEIGHT>';
	  l_xml_body:= l_xml_body||l_new_line||'<COMP_FN_QRY>'||format_string(l_score_comp_val)||'</COMP_FN_QRY>';
	  exception
	   when others then
	    FND_FILE.PUT_LINE(FND_FILE.LOG, 'error in score objects in getting score component details'||sqlerrm);
           IEX_DEBUG_PUB.logMessage('error in score objects in getting score component details'||sqlerrm);
         end;


       begin
        select count(*)
	 into l_cnt
	 from iex_score_comp_det
	 where score_component_id=l_components_tbl(comp).score_component_id;
--	  FND_FILE.PUT_LINE(FND_FILE.LOG,'count in comp_det tab-->'||l_cnt);
	    for cnt in 1..l_cnt loop
	      select range_low,range_high,new_value
	     bulk collect into l_sc_range_low,l_sc_range_high,l_sc_val
	     from iex_score_comp_det sc_det
	    where score_component_id=l_components_tbl(comp).score_component_id;
	   end loop;
           if l_sc_range_low.count > 0 then
	    for val in l_sc_range_low.first..l_sc_range_low.last loop
             l_xml_body:= l_xml_body||l_new_line||'<COMP_RANGE>';
	     l_xml_body:=l_xml_body||l_new_line||'<COMP_RANGE_LOW>'||l_sc_range_low(val)||'</COMP_RANGE_LOW>';
             l_xml_body:=l_xml_body||l_new_line||'<COMP_RANGE_HIGH>'||l_sc_range_high(val)||'</COMP_RANGE_HIGH>';
              l_xml_body:=l_xml_body||l_new_line||'<COMP_RANGE_VAL>'||l_sc_val(val)||'</COMP_RANGE_VAL>';
              l_xml_body:= l_xml_body||l_new_line||'</COMP_RANGE>';
	    end loop;
	   end if;

	--   FND_FILE.PUT_LINE(FND_FILE.LOG,'out of comp_det loop');
	  l_xml_body:= l_xml_body||l_new_line||'</COMPONENT>';
	   exception
	   when others then
	    FND_FILE.PUT_LINE(FND_FILE.LOG, 'error in score objects in getting score component cnt/range details'||sqlerrm);
           IEX_DEBUG_PUB.logMessage('error in score objects in getting score component cnt/range details'||sqlerrm);
           end;
	end loop;
      end if;

	--  FND_FILE.PUT_LINE(FND_FILE.LOG, '***close component details***');
      --    FND_FILE.PUT_LINE(FND_FILE.LOG,'tempres-->'||tempResult);
       --End Bug 8933776 30-Nov-2009 barathsr


            Select IEX_DEL_WF_S.NEXTVAL INTO l_del_buff_bridge FROM Dual;  --Added by schekuri for bug#6373998 on 31-Aug-2007
	    FND_FILE.PUT_LINE(FND_FILE.LOG,'Using bridge ' || l_del_buff_bridge || ' one for each scoring engine');
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreObjects: got bridge id ' || l_del_buff_bridge || ' once for each scoring engine');
      END IF;

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreObjects: building Universe');
      END IF;



              -- start for bug 9387044
			-- bug#5586925 score in loop to increase scaleablility
	/*		l_last_batch := false;
			while not l_last_batch loop
	      l_universe  := iex_filter_pub.buildUniverse(p_object_id          => p_score_id,
	                                                  p_query_obj_id       => p_unv_obj_id, --Added for Bug 8933776 17-Dec-2009 barathsr
							  p_limit_rows         => p_limit_rows_val, --Added for Bug 8933776 17-Dec-2009 barathsr
	                                                  p_object_type        => 'IEXSCORE',
	                                                  p_last_object_scored => l_last_obj_scored,
	                                                  x_end_of_universe    => l_last_batch);

				IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreObjects: last object ' || l_last_obj_scored);

	      if (l_universe is null or l_universe.count < 1) and not l_last_batch then
	          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	             IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreObjects: Universe size is zero');
	          END IF;
	          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Universe Size is Zero or Invalid for Engine ' || p_score_id);

	          FND_MESSAGE.Set_Name('IEX', 'IEX_UNIVERSE_SIZE_ZERO');
	          FND_MSG_PUB.Add;

	         --START jsanju 10/19/05 for bug 3549051
	          --RAISE FND_API.G_EXC_ERROR;
	            RAISE IEX_UNIVERSE_SIZE_ZERO_ERROR;
	         --END jsanju 10/19/05 for bug 3549051

	      end if;  */

	      l_count := 0;
	      l_universe_size:=0;
	      univ_size:=0;
              vsql := iex_filter_pub.buildsql(p_object_id   => p_score_id, p_object_type => 'IEXSCORE',p_query_obj_id       => p_unv_obj_id, --Added for Bug 9670348 27-May-2009 barathsr
							  p_limit_rows         => p_limit_rows_val);--Added for Bug 9670348 27-May-2009 barathsr

               open universe_cur for vsql;

	      loop
		 l_universe.delete;

		 l_count := l_count +1;
		 fetch universe_cur bulk collect into l_universe limit G_BATCH_SIZE;

	         if (l_universe is null or l_universe.count < 1) and l_count = 1 then
	             l_return := fnd_concurrent.set_completion_status (status  => 'WARNING',
	                                                               message => 'Zero objects scored. Check object filter of the Scoring engine');
	         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Warning!!! Zero objects scored. Check object filter of the Scoring engine ');
	         close universe_cur;
	         return;  -- bug 9570425
		 end if;

                 FND_FILE.PUT_LINE(FND_FILE.LOG,'Scoring objects in batch ' || l_count || ' is ' || l_universe.count || ' at ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSS') );
	         if l_universe.count = 0 then
	            close universe_cur;
	            exit;
	         end if;

	        univ_size := l_universe.count;
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'universe size ' ||univ_size);
		l_universe_size:=l_universe_size+univ_size;

		--Begin Bug 8933776 30-Nov-2009 barathsr
		if l_count=1 then
		  l_xml_body:= l_xml_body||l_new_line||'</COMPONENTS>';
                  dbms_lob.writeAppend(tempResult, length(l_xml_body), l_xml_body);
                --End Bug 8933776 30-Nov-2009 barathsr
                 end if;


	      -- begin clchang added 10/20/04 for 11.5.11 score engine enhancement
	      -- get the score_range_low, score_range_high, out_of_range_rule, and
	      -- weight_required of this given score engine;
	      iex_score_new_pvt.getScoreRange(p_score_id       => p_score_id );
	      -- if weight_required is Y, then chk weight of each comp is null or not;
	      IF (IEX_SCORE_NEW_PVT.G_WEIGHT_REQUIRED = 'Y') Then
	        FOR i in 1..l_components_tbl.count
	        LOOP
	           if (l_components_tbl(i).score_comp_weight is null) then
	             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	               IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreObjects: no comp weight');
	             END IF;
	             FND_FILE.PUT_LINE(FND_FILE.LOG,
	                               'Score Comp Weight are required for Engine '|| p_score_id);
	             FND_MESSAGE.Set_Name('IEX', 'IEX_WEIGHT_REQUIRED');
	             FND_MSG_PUB.Add;
	             RAISE FND_API.G_EXC_ERROR;
	           end if;
	        END LOOP;
	      END IF;
	      -- end  clchang added 10/20/04 for 11.5.11 score engine enhancement

	      -- get the scores for the Universe
	      --Begin Bug 8933776 30-Nov-2009 barathsr
	      if l_count=1 then
	      l_xml_body:= l_new_line||'<COMP_DETAILS>';
	       -- l_xml_body:=l_xml_body||l_new_line||'<COMP_DET>';
	       dbms_lob.writeAppend(tempResult, length(l_xml_body), l_xml_body);
	       end if;
	       --End Bug 8933776 30-Nov-2009 barathsr
	      iex_score_new_pvt.getScores(p_score_comp_tbl => l_components_tbl,
	                                  t_object_ids     => l_universe,
	                                  x_scores_tbl     => l_scores_tbl);
		--l_xml_body:=l_new_line||'</COMP_DET>';
		    end loop;

		    --Begin Bug 8933776 30-Nov-2009 barathsr
	         l_xml_body:=l_new_line||'</COMP_DETAILS>';
		 l_xml_body:= l_xml_body||l_new_line||'<UNIV_SIZE>'||l_universe_size||'</UNIV_SIZE>';
		  dbms_lob.writeAppend(tempResult, length(l_xml_body), l_xml_body);
		  --End Bug 8933776 30-Nov-2009 barathsr

			l_bridge := l_scores_tbl(1); -- The table now contains the bridge to the next concurrent program or nothing


       FND_FILE.PUT_LINE(FND_FILE.LOG, ' Completed Scoring ' || ' objects of type ' || l_object_type);
      Begin
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreObjects: Finding any process to spawn...');
          END IF;
          Select NVL(cp.Concurrent_Program_Name, 'X')
            Into l_conc_prog_name
            From IEX_SCORES scr, fnd_concurrent_programs cp
            Where scr.concurrent_prog_name = cp.concurrent_program_name AND
                 scr.Score_ID = p_score_id;
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'IEX_SCORE: scoreObjects: Spawning ' || l_conc_prog_name);

           --- Begin - Eun Huh  - 02/15/2007 - bug 5763675/5696238 if run multiple Scoring Engine Harness program at the same time it will pick up only the last one always
            --select MAX(request_id)
                -- into l_bridge
                -- from iex_del_buffers
                -- where PROGRAM_APPLICATION_ID = l_prog_appl
                --   and PROGRAM_ID = l_program
                --   and CREATED_BY = l_user;

	    --- End - LKKUMAR - 13-Apr-2006. Replace the SQL with MAX. --Bug5154199.

             -- spawn proces if conc_prog_id is there
             if l_conc_prog_name <> 'X' then
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreObjects: spawning ' || l_conc_prog_name ||
                   ' with bridge ' || l_bridge);
                END IF;

		--Start MOAC
		fnd_request.set_org_id(mo_global.get_current_org_id);

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreObjects: spawning ' || l_conc_prog_name || ' for operating unit: ' ||  nvl(mo_global.get_ou_name(mo_global.get_current_org_id), 'All'));
    END IF;
		--End MOAC

                l_submit_request_id := FND_REQUEST.SUBMIT_REQUEST(
                                        APPLICATION       => 'IEX',
                                        PROGRAM           => l_conc_prog_name,
                                        DESCRIPTION       => 'Oracle Collections Score Engine Spawned Process for Operating Unit: '||
					                               nvl(mo_global.get_ou_name(mo_global.get_current_org_id), 'All'),
                                        START_TIME        => sysdate,
                                        SUB_REQUEST       => false,
                                        ARGUMENT1         => l_bridge);
                COMMIT;

                 -- Begin - schekuri - 6156648 - 10/Jun/2007 - Adding wait for request to try to make it wait
                 bReturn := FND_CONCURRENT.WAIT_FOR_REQUEST(l_submit_request_id,60,0,vReturn,vReturn,vReturn,vReturn,vReturn);
                 -- End - schekuri - 6156648 - 10/Jun/2007 - Adding wait for request to try to make it wait


              --jsanju 06/21/04
              --the main process should wait till the spawned process is
              --over.
                IF (l_submit_request_id IS NOT NULL AND l_submit_request_id  <> 0) THEN
                   LOOP
                        FND_FILE.PUT_LINE(FND_FILE.LOG,
                        'Start Time of the spawned Process ' ||
                         l_conc_prog_name || ' =>'||to_char (sysdate, 'dd/mon/yyyy :HH:MI:SS'));
                         l_bool := FND_CONCURRENT.wait_for_request(
                                   request_id =>l_submit_request_id,
                                   interval   =>30,
                                   max_wait   =>144000,
                                   phase      =>uphase,
                                   status     =>ustatus,
                                   dev_phase  =>dphase,
                                   dev_status =>dstatus,
                                   message    =>message);

                         IF dphase = 'COMPLETE'
                            --and dstatus = 'NORMAL' --the possible
                                    --values are NORMAL/ERROR/WARNING/CANCELLED/TERMINATED
                          THEN
                           FND_FILE.PUT_LINE(FND_FILE.LOG,
                           'End Time of the spawned Process ' ||
                            l_conc_prog_name || ' =>'||to_char (sysdate, 'dd/mon/yyyy :HH:MI:SS'));
                          EXIT;
                        END If; --dphase

                  END LOOP;
               END IF; -- if l_submit
               FND_FILE.PUT_LINE(FND_FILE.LOG, 'IEX_SCORE: scoreObjects: Launched cp '
                                  || l_submit_request_id || ' successfully');
	       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Operating Unit: ' ||  nvl(mo_global.get_ou_name(mo_global.get_current_org_id), 'All')); --Added OU Name for MOAC
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreObjects: process spawned '
                                  || l_submit_request_id);
               END IF;

             end if; --if conc_process is not 'X'
        Exception
             WHEN NO_DATA_FOUND THEN

                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreObjects: no process spawned');
                END IF;
                NULL;
        End;
        --
        -- End of API body
        --

        -- Standard check for p_commit
        IF FND_API.to_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.logMessage('scoreObjects: ' || 'PUB: ' || l_api_name || ' end');
           IEX_DEBUG_PUB.logMessage('scoreObjects: ' || 'End time:'|| TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
        END IF;

        FND_MSG_PUB.Count_And_Get
        (p_count => x_msg_count,
         p_data  => x_msg_data);
           --Begin Bug 8933776 30-Nov-2009 barathsr
          l_xml_body:=l_new_line||'</SCOREDET>'||l_new_line;
         dbms_lob.writeAppend(tempResult, length(l_xml_body), l_xml_body);
	 --End Bug 8933776 30-Nov-2009 barathsr

	-- FND_FILE.PUT_LINE(FND_FILE.LOG, '***close score details body***');

        EXCEPTION
            WHEN FND_API.G_EXC_ERROR THEN
                 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreObjects: Expected Error ' || sqlerrm);
                 END IF;
                 RAISE FND_API.G_EXC_ERROR;
                 ROLLBACK TO scoreObjects_PVT;

            WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreObjects: UnExpected Error ' || sqlerrm);
                 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ROLLBACK TO scoreObjects_PVT;

           --START jsanju 10/19/05 for bug 3549051, pass the exception to the score_concur procedure

            WHEN IEX_UNIVERSE_SIZE_ZERO_ERROR THEN
                 ROLLBACK TO scoreObjects_PVT;
                 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreObjects: iex universe size zero Error ' || x_msg_data);
                 END IF;

                 RAISE IEX_UNIVERSE_SIZE_ZERO_ERROR;

            WHEN OTHERS THEN
                 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreObjects: Other Error ' || sqlerrm);
                 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ROLLBACK TO scoreObjects_PVT;

END scoreObjects;

/*
|| Overview:    score a single object given it's ID, it's Type, and it's Scoring Engine
||
|| Parameter:   p_score_id => scoring engine ID
||
|| Source Tables:   IEX_SCORES, IEX_SCORE_COMPONENTS_VL, IEX_SCORE_COMP_TYPES, IEX_SCORE_COMP_DET,
||                  IEX_OBJECT_FILTERS
||
|| Target Tables:
||
|| Creation date:       01/22/02 3:14:PM
||
|| Major Modifications: when            who                       what
||                      01/22/02        raverma             created
*/
function scoreObject(p_commit         IN VARCHAR2,
                     P_OBJECT_ID      IN NUMBER,
                     P_OBJECT_TYPE    IN VARCHAR2,
                     P_SCORE_ID       IN NUMBER) RETURN NUMBER

IS
    --vPLSQL           varchar2(5000);
    l_universe       IEX_FILTER_PUB.UNIVERSE_IDS;  -- for TestUniverse / testGetScores
    l_components_tbl IEX_SCORE_NEW_PVT.SCORE_ENG_COMP_TBL;  -- for testGetComponents / testGetScores

    l_scores_tbl     IEX_SCORE_NEW_PVT.SCORES_TBL;  -- fore testGetScores
    l_score_id       number ;
    l_object_type    varchar2(25) ;
    b_valid          boolean;

BEGIN

    l_score_id       := p_score_id;
    l_object_type    := p_object_type;

    b_valid := validateObjectID (p_object_id   => p_object_id,
                                 p_object_type => p_object_type);

    if not b_valid then
        FND_MESSAGE.Set_Name('IEX', 'IEX_INVALID_SCORING_OBJECT');
        FND_MSG_PUB.Add;
        return -1;
    end if;

    b_valid := iex_score_new_pvt.checkObject_Compatibility(p_score_id    => l_score_id ,
                                                           p_object_type => l_object_type);
    if not b_Valid then
        FND_MESSAGE.Set_Name('IEX', 'IEX_INVALID_SCORING_ENGINE');
        FND_MSG_PUB.Add;
        return -1;
    end if;

    IEX_SCORE_NEW_PVT.getCOMPONENTS(p_score_id       => l_score_id,
                                    x_score_comp_tbl => l_components_tbl);

    -- in case of singular object scoring we can ignore universe?
    l_universe(1) := p_object_id;

--- Begin - Andre Araujo - 11/02/2004 - Changed storage method, this storage desgin blows up at 414526 records - TAR 4040621.994

    l_scores_tbl(1) := get1Score( l_components_tbl, p_object_id );

    return l_scores_tbl(1);
--  iex_score_new_pvt.getScores(p_score_comp_tbl => l_components_tbl,
--                              t_object_ids     => l_universe,
--                              x_scores_tbl     => l_scores_tbl);
--
--  if (l_scores_tbl is not null) and (l_scores_tbl.count > 0) then
--      IF FND_API.to_Boolean(p_commit)
--      THEN
--             insert into iex_score_histories(SCORE_HISTORY_ID
--                                             ,SCORE_OBJECT_ID
--                                             ,SCORE_OBJECT_CODE
--                                             ,OBJECT_VERSION_NUMBER
--                                             ,LAST_UPDATE_DATE
--                                             ,LAST_UPDATED_BY
--                                             ,LAST_UPDATE_LOGIN
--                                             ,CREATION_DATE
--                                             ,CREATED_BY
--                                             ,SCORE_VALUE
--                                             ,SCORE_ID
--                                             ,REQUEST_ID)
--                          values(IEX_SCORE_HISTORIES_S.nextval
--                                 ,l_universe(1)
--                                 ,l_object_type
--                                 ,1
--                                 ,sysdate
--                                 ,FND_GLOBAL.USER_ID
--                                 ,FND_GLOBAL.USER_ID
--                                 ,sysdate
--                                 ,FND_GLOBAL.USER_ID
--                                 ,l_scores_tbl(1)
--                                 ,p_score_id
--                                 ,nvl(FND_GLOBAL.Conc_REQUEST_ID,0));
--
--      END IF;
--
--      return l_scores_tbl(1);
--   else
--      return -1;
--   end if;
--
--- End - Andre Araujo - 11/02/2004 - Changed storage method, this storage desgin blows up at 414526 records - TAR 4040621.994
--
END scoreObject;

/* this will be called by the concurrent program to score customers
 */
Procedure Score_Concur(ERRBUF       OUT NOCOPY VARCHAR2,
                       RETCODE      OUT NOCOPY VARCHAR2,
		       P_ORG_ID IN NUMBER,    --Added for MOAC
		       P_SCORE_ID1  IN NUMBER,
                       P_Score_ID2  IN NUMBER,
                       P_Score_ID3  IN NUMBER,
                       P_Score_ID4  IN NUMBER,
                       P_Score_ID5  IN NUMBER,
		       p_show_output in varchar2 default null,--Added for Bug 8933776 30-Nov-2009 barathsr
		       p_object_id in varchar2,--Added for Bug 8933776 17-Dec-2009 barathsr
		       p_limit_rows in number)--Added for Bug 8933776 17-Dec-2009 barathsr
		       --Added for Bug 8933776 30-Nov-2009 barathsr
IS

    l_return_status VARCHAR2(10);
    l_msg_data      VARCHAR2(32767);
    l_msg_count     NUMBER;

    -- bug 6128024
    l_pf_name       varchar2(100);
    l_pf_value      varchar2(50) := nvl(FND_PROFILE.VALUE('XLA_MO_SECURITY_PROFILE_LEVEL'),'');

type score_ids is table of number index by binary_integer;
l_num_score_engines score_ids;

 -- START -jsanju 10/19/05 , set concurrent status to 'WARNING' if universe size exception occurs for bug 3549051
    request_status BOOLEAN;
 -- END  -jsanju 10/19/05 , set concurrent status to 'WARNING' if universe size exception occurs for bug 3549051

 l_xml_header clob;
 l_xml_header_length number;
 l_close_tag clob;
 l_org_id varchar2(100);
 l_api_name varchar2(100):='Score_Concur';
 l_score_name1 varchar2(200);
 l_score_name2 varchar2(200);
 l_score_name3 varchar2(200);
 l_score_name4 varchar2(200);
 l_score_name5 varchar2(200);
 --Begin Bug 8933776 30-Nov-2009 barathsr
 l_show_out varchar2(10);
 l_obj_ids varchar2(10);
 l_max_rows varchar2(10);
 --End Bug 8933776 30-Nov-2009 barathsr



BEGIN

    RETCODE := 0;
    l_num_score_engines(1) := p_score_id1;
    l_num_score_engines(2) := p_score_id2;
    l_num_score_engines(3) := p_score_id3;
    l_num_score_engines(4) := p_score_id4;
    l_num_score_engines(5) := p_score_id5;

    ---start moac
    MO_GLOBAL.INIT('IEX');
    if p_org_id is null then
      mo_global.set_policy_context('M',NULL);
    else
      mo_global.set_policy_context('S',p_org_id);
    end if;

    ---end moac

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.logMessage('Score_Concur: ' || 'IEX_SCORE: scoreConcur: Scoring Harness Accessed');
       IEX_DEBUG_PUB.logMessage('Score_Concur: ' || 'IEX_SCORE: scoreConcur: Start time:'|| TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;

    -- Begin bug 6128024
    begin
       select security_profile_name into l_pf_name from per_security_profiles
         where security_profile_id = l_pf_value;
      exception
         when others then l_pf_name := null;
    end;

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Profile Value MO: Default Operating Unit : ' || NVL(mo_global.get_ou_name(FND_PROFILE.VALUE('DEFAULT_ORG_ID')), ' '));
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Profile Value MO: Operating Unit: ' || NVL(mo_global.get_ou_name(FND_PROFILE.VALUE('ORG_ID')), ' '));
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Profile Value MO: Security Profile: ' || l_pf_name);
    FND_FILE.PUT_LINE(FND_FILE.LOG, '                                      ');
    -- End bug 6128024

    --Begin Bug 8933776 30-Nov-2009 barathsr
    begin
	    if p_org_id is not null then
		  select name
		  into l_org_id
		  from hr_operating_units
		  where organization_id=p_org_id;
		else
		  l_org_id:='All';
	    end if;

    FND_FILE.PUT_LINE(FND_FILE.LOG, '***start of xml hdr***');

     l_xml_header     := '<?xml version="1.0" encoding="UTF-8"?>';
     l_xml_header:=l_xml_header||l_new_line||'<SCORE_REPORT>';
     l_xml_header:=l_xml_header||l_new_line||'<PARAMETERS>';
     l_xml_header:=l_xml_header||l_new_line||'<ORG_ID>'||l_org_id||'</ORG_ID>';
     if p_score_id1 is not null then
      select score_name into l_score_name1 from iex_scores where score_id=p_score_id1;
     else
      l_score_name1:='NA';
     end if;
     l_xml_header:=l_xml_header||l_new_line||'<SCORE_ENGINE_1>'||format_string(l_score_name1)||'</SCORE_ENGINE_1>';
     if p_score_id2 is not null then
      select score_name into l_score_name2 from iex_scores where score_id=p_score_id2;
     else
      l_score_name2:='NA';
     end if;
     l_xml_header:=l_xml_header||l_new_line||'<SCORE_ENGINE_2>'||format_string(l_score_name2)||'</SCORE_ENGINE_2>';
     if p_score_id3 is not null then
      select score_name into l_score_name3 from iex_scores where score_id=p_score_id3;
     else
      l_score_name3:='NA';
     end if;
     l_xml_header:=l_xml_header||l_new_line||'<SCORE_ENGINE_3>'||format_string(l_score_name3)||'</SCORE_ENGINE_3>';
     if p_score_id4 is not null then
      select score_name into l_score_name4 from iex_scores where score_id=p_score_id4;
     else
      l_score_name4:='NA';
     end if;
     l_xml_header:=l_xml_header||l_new_line||'<SCORE_ENGINE_4>'||format_string(l_score_name4)||'</SCORE_ENGINE_4>';
     if p_score_id5 is not null then
      select score_name into l_score_name5 from iex_scores where score_id=p_score_id5;
     else
      l_score_name5:='NA';
     end if;
     l_xml_header:=l_xml_header||l_new_line||'<SCORE_ENGINE_5>'||format_string(l_score_name5)||'</SCORE_ENGINE_5>';
  /*   if nvl(p_show_output,'No')='Yes' then
     l_show_out:='Yes';
     else
     l_show_out:='No';
     end if;*/
     if p_object_id is not null then
     l_xml_header:=l_xml_header||l_new_line||'<OBJ_IDS>'||p_object_id||'</OBJ_IDS>';
     else
     l_obj_ids:='NA';
     l_xml_header:=l_xml_header||l_new_line||'<OBJ_IDS>'||l_obj_ids||'</OBJ_IDS>';
     end if;
     if p_limit_rows is not null then
     l_xml_header:=l_xml_header||l_new_line||'<MAX_ROWS>'||p_limit_rows||'</MAX_ROWS>';
     else
     l_max_rows:='NA';
     l_xml_header:=l_xml_header||l_new_line||'<MAX_ROWS>'||l_max_rows||'</MAX_ROWS>';
     end if;
     l_xml_header:=l_xml_header||l_new_line||'<SHOW_OUTPUT>'||p_show_output||'</SHOW_OUTPUT>';
     l_xml_header:=l_xml_header||l_new_line||'</PARAMETERS>';
     l_close_tag:='</SCORE_REPORT>'||l_new_line;

     l_xml_header_length := length(l_xml_header);
  --    tempResult := l_xml_header;
 --  FND_FILE.put_line( FND_FILE.LOG,'Constructing the XML Header is success');

   dbms_lob.createtemporary(tempResult,FALSE,DBMS_LOB.CALL);
   dbms_lob.open(tempResult,dbms_lob.lob_readwrite);
   dbms_lob.writeAppend(tempResult, length(l_xml_header), l_xml_header);
   FND_FILE.put_line( FND_FILE.LOG,'Constructing the XML Header is success');
   exception
     when others then
       FND_FILE.put_line( FND_FILE.LOG,'err in xml header-->'||sqlerrm);
       iex_debug_pub.LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME || '.' || l_api_name || '-'||sqlerrm);
   end;
   --End Bug 8933776 30-Nov-2009 barathsr

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Batch Size: ' || G_BATCH_SIZE);
    for x in 1..5 loop
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Running Scoring Engine: ' || to_char(l_num_score_engines(x)));
	  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Operating Unit: ' || nvl(mo_global.get_ou_name(mo_global.get_current_org_id), 'All')); --Added for moac
          if l_num_score_engines(x) is not null then
                BEGIN
                    IEX_SCORE_NEW_PVT.scoreObjects(p_api_version   => 1.0,
                                                   p_init_msg_list => FND_API.G_TRUE,
                                                   p_commit        => FND_API.G_TRUE,
                                                   x_return_status => l_return_status,
                                                   x_msg_count     => l_msg_count,
                                                   x_msg_data      => l_msg_data,
                                                   p_score_id      => l_num_score_engines(x),
						   p_unv_obj_id    => p_object_id,--Added for Bug 8933776 17-Dec-2009 barathsr
						   p_limit_rows_val => p_limit_rows);--Added for Bug 8933776 30-Nov-2009 barathsr
                   FND_FILE.PUT_LINE(FND_FILE.LOG,
                                     'Score Engine: ' || l_num_score_engines(x) ||
                                     ' Status: ' || l_return_status);



                    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
                         RAISE FND_API.G_EXC_ERROR;
                    end if;




                EXCEPTION

                    -- note do not set retcode when error is expected
                    WHEN FND_API.G_EXC_ERROR THEN
                               RETCODE := -1;
                               ERRBUF := l_msg_data;
                               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                               IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreConcur: Expected Error in Score ' || sqlerrm);
                               END IF;
                               FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR IN CONCUR: '  || sqlerrm || ERRBUF);

                  -- START -jsanju 10/19/05 , set concurrent status to 'WARNING' if universe size exception occurs for bug 3549051
                    WHEN IEX_UNIVERSE_SIZE_ZERO_ERROR THEN
                               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                 IEX_DEBUG_PUB.logMessage('IEX_SCORE: universe size is zero ' || l_msg_data);
                               END IF;
                               FND_FILE.PUT_LINE(FND_FILE.LOG, 'Universe Size is Zero  ');
                               request_status := fnd_concurrent.set_completion_status('WARNING'
                                          , 'Universe size is zero');

                -- END  -jsanju 10/19/05 , set concurrent status to 'WARNING' if universe size exception occurs for bug 3549051

                    WHEN OTHERS THEN
                               RETCODE := -1;
                               ERRBUF := l_msg_data;
                               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                               IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreConcur: Unexpected Error ' || sqlerrm);
                               END IF;
                               FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR IN CONCUR: ' || sqlerrm || ERRBUF);
                END;

         end if;
    end loop;

      FND_FILE.PUT_LINE(FND_FILE.LOG,'1');
				     dbms_lob.writeAppend(tempResult, length(l_close_tag), l_close_tag);
				     --print to the o/p file
				     FND_FILE.PUT_LINE(FND_FILE.LOG,'2');
				     FND_FILE.PUT_LINE(FND_FILE.LOG,'len_tempRes-->'||length(tempResult));
				  --   FND_FILE.PUT_LINE(FND_FILE.LOG,substr(tempResult,16000,length(tempResult)));
				     if nvl(p_show_output,'No')='Yes' then
                                   print_clob(lob_loc => tempResult);
				   else
				       tempResult:=l_xml_header;
                                 --       dbms_lob.writeAppend(tempResult, length(l_xml_header), l_xml_header);
                                         dbms_lob.writeAppend(tempResult, length(l_close_tag), l_close_tag);
                                    print_clob(lob_loc => tempResult);
				     end if;
                                 --  Fnd_File.PUT_line(FND_FILE.LOG,substr(tempResult,1,length(tempResult)));
				   FND_FILE.PUT_LINE(FND_FILE.LOG,'3');

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.logMessage('Score_Concur: ' || 'Return status is ' || l_return_status);
       IEX_DEBUG_PUB.logMessage('Score_Concur: ' || 'IEX_SCORE: scoreConcur: End time:'|| TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;
Exception

    WHEN FND_API.G_EXC_ERROR THEN
               RETCODE := -1;
               ERRBUF := l_msg_data;
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreConcur: Expected Error ' || sqlerrm);
               END IF;
               FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR IN CONCUR: '  || sqlerrm);

    WHEN OTHERS THEN
               RETCODE := -1;
               ERRBUF := l_msg_data;
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreConcur: Unexpected Error ' || sqlerrm);
               END IF;
               FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR IN CONCUR: ' || sqlerrm);
END SCORE_CONCUR;

/*
|| Overview:    delete rows from IEX_SCORE_HISTORIES to improve performance
||
|| Parameter:   p_score_object_code => score_object_code to erase
||              p_from_date         => remove from this date
||              p_to_Date           => remove up to this date
||              p_request_id        => remove this request
||              p_save_last_run     => save the last run of the object type
||              all parameters are AND logic on the where clause
||
|| Source Tables:
||
|| Target Tables:  IEX_SCORE_HISTORIES
||
|| Creation date:  01/28/03 3:14:PM
||
|| Major Modifications: when            who                       what
||                      01/28/03        raverma                created
*/
Procedure eraseScores(ERRBUF              OUT NOCOPY VARCHAR2,
                      RETCODE             OUT NOCOPY VARCHAR2,
                      P_TRUNCATE          IN VARCHAR2,  -- fix a bug 5765878 to truncate table to perform better by Ehuh 02.19.2007
                      P_SCORE_OBJECT_ID   IN NUMBER ,
                      P_SCORE_OBJECT_CODE IN VARCHAR2 ,
        -- begin bug 4504193 by ctlee 2005/07/26 - update from date to varchar2
                      P_FROM_DATE         IN varchar2 ,
                      P_TO_DATE           IN varchar2 ,
        -- end bug 4504193 by ctlee 2005/07/26 - update from date to varchar2
                      P_REQUEST_ID        IN NUMBER ,
                      P_SAVE_LAST_RUN     IN VARCHAR2,
                      P_BATCH_SIZE        IN NUMBER)
IS

  vPLSQL              VARCHAR2(200);
  vPLSQL2             VARCHAR2(500);
  l_total             NUMBER(38) ;
  l_Count             NUMBER     ;
  i                   NUMBER     ;
  j                   NUMBER     ;
  l_object_code       VARCHAR2(50);
  Type refCur         is Ref Cursor;
  sql_cur             refCur;
  l_conditions        IEX_UTILITIES.Condition_Tbl;
  l_msg_data          VARCHAR2(1000);
  l_score_history_ids IEX_FILTER_PUB.UNIVERSE_IDS;

  -- clchang updated for sql bind var 05/07/2003
  vStr1               VARCHAR2(100) ;
  vStr2               VARCHAR2(100) ;
  vSqlCur             VARCHAR2(1000) ;
  -- end

  -- Modified By Surya 11/18/2003 Bug 3221769
  v_del_sql         Varchar2(1000)  ;
  v_tot_objects     Number := 0 ;

  -- Andre Added
  vWhereClause         VARCHAR2(1000) ;
  vSelectCount         Varchar2(1000) ;
  vLoopCount           Number;

  --clchang 10/29/04 added to fix gscc
  l_save_last_run     varchar2(10);

  -- begin bug 4504193 by ctlee 2005/07/26
  v_from_date date;
  v_to_date date;
  -- end bug 4504193 by ctlee 2005/07/26

  l_prod              varchar2(04) := 'iex'; -- fix a bug 5765878 to truncate table to perform better by Ehuh 02.19.2007
  v_num               NUMBER;  --Added for bug 8605501 gnramasa 20th Oct 09

BEGIN

    --clchang 10/29/04 added to fix gscc
    -- and before P_SAVE_LAST_RUN has DEFAULT 'Y';
    l_save_last_run := p_save_last_run;
    if ( l_save_last_run is null) then
       l_save_last_run := 'Y';
    end if;
    -- no default values in declare
    l_total             := 0;
    l_Count             := 0;
    i                   := 0;
    j                   := 0;
    vStr1      := 'SELECT SCORE_HISTORY_ID ' ;
    vStr2      := ' FROM IEX_SCORE_HISTORIES ' ;
    v_del_sql  :=  'DELETE FROM IEX_SCORE_HISTORIES ' ;
    vWhereClause   := '';
    vSelectCount   := 'select count(1) from iex_score_histories ';


--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.logMessage('IEX_SCORE: eraseScores');
       IEX_DEBUG_PUB.logMessage('IEX_SCORE: eraseScores: Start time:'|| TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;

    /* build where clause */
    if P_SCORE_OBJECT_ID IS NOT NULL then
        FND_FILE.PUT_LINE(FND_FILE.LOG,P_SCORE_OBJECT_ID);
        i:= i + 1;
        l_conditions(i).Col_Name := 'SCORE_OBJECT_ID';
        l_conditions(i).Condition := '=';
        l_conditions(i).Value := P_SCORE_OBJECT_ID;
    end if;
    if P_SCORE_OBJECT_CODE IS NOT NULL then
        FND_FILE.PUT_LINE(FND_FILE.LOG,P_SCORE_OBJECT_CODE);
        i := i + 1;
        l_conditions(i).Col_Name := 'SCORE_OBJECT_CODE';
        l_conditions(i).Condition := '=';
        l_conditions(i).Value := '''' || P_SCORE_OBJECT_CODE || '''';
    end if;
    if P_FROM_DATE IS NOT NULL then
        FND_FILE.PUT_LINE(FND_FILE.LOG,TO_CHAR(P_FROM_DATE));
        i := i + 1;
        l_conditions(i).Col_Name := 'CREATION_DATE';
        l_conditions(i).Condition := '>';
        -- l_conditions(i).Value := '''' || to_char(P_FROM_DATE) || '''';
        -- begin bug 4504193 by ctlee 2005/07/26
        v_from_date := to_date(p_from_date, 'yyyy/mm/dd hh24:mi:ss');
        l_conditions(i).Value := '''' || to_char(v_FROM_DATE) || '''';
        -- end bug 4504193 by ctlee 2005/07/26
    end if;
    if P_TO_DATE IS NOT NULL then
        FND_FILE.PUT_LINE(FND_FILE.LOG,TO_CHAR(P_TO_DATE));
        i := i + 1;
        l_conditions(i).Col_Name := 'CREATION_DATE';
        l_conditions(i).Condition := '<=';
        -- l_conditions(i).Value := '''' || to_char(P_TO_DATE) || '''';
        -- begin bug 4504193 by ctlee 2005/07/26
        v_to_date := to_date(p_to_date, 'yyyy/mm/dd hh24:mi:ss');
        l_conditions(i).Value := '''' || to_char(v_TO_DATE) || '''';
        -- end bug 4504193 by ctlee 2005/07/26
    end if;
    if P_REQUEST_ID IS NOT NULL then
        FND_FILE.PUT_LINE(FND_FILE.LOG,P_REQUEST_ID);
        i := i + 1;
        l_conditions(i).Col_Name := 'REQUEST_ID';
        l_conditions(i).Condition := '=';
        l_conditions(i).Value := P_REQUEST_ID;
    end if;
    --if P_SAVE_LAST_RUN <> 'N' then
    if L_SAVE_LAST_RUN <> 'N' then
        FND_FILE.PUT_LINE(FND_FILE.LOG,L_SAVE_LAST_RUN);
        -- Begin - Andre Araujo - 03/02/2005 - BUG#4198055 - Did not increase the count, causes not found exception
        i := i + 1;
        l_conditions(i).Col_Name := 'trunc(CREATION_DATE)';
        l_conditions(i).Condition := '<>';
        l_conditions(i).Value := '(SELECT trunc(MAX(creation_date)) FROM iex_Score_histories)'; -- Andre Fixed here so we use date only
        --l_conditions(i).Col_Name := 'CREATION_DATE';
        --l_conditions(i).Condition := '<>';
        --l_conditions(i).Value := '(SELECT MAX(creation_date) FROM iex_Score_histories)';
        -- End - Andre Araujo - 03/02/2005 - BUG#4198055 - Did not increase the count, causes not found exception
    end if;

    -- Added by Surya
    if l_conditions.COUNT >= 1 then

        vPLSQL2 := IEX_UTILITIES.buildWhereClause(l_conditions);

        If NVL(p_truncate,'Y') = 'N' then -- fix a bug 5765878 to truncate table to perform better by Ehuh 2.19.2007
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Delete Filter Applied => '||  vPLSQL2);
        end if;

           v_del_sql := v_del_sql || VPLSQL2 ;
    End If ;

    -- Andre Added
    vWhereClause := VPLSQL2;

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage(vPLSQL2);
    END IF;

    If NVL(p_truncate,'Y') = 'N' then -- fix a bug 5765878 to truncate table to perform better by Ehuh 2.19.2007
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'SELECT SCORE_HISTORY_ID ' ||
                                    ' FROM IEX_SCORE_HISTORIES ' ||
                                    vPLSQL2);
    End if;

    vPLSQL := '  SELECT Count(1), Score_object_code ' ||
              '    FROM IEX_SCORE_HISTORIES ' ||
              'GROUP BY SCORE_OBJECT_CODE ';

    FND_FILE.PUT_LINE(FND_FILE.LOG, '-------------------------------------------------');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '                  BEFORE PURGE');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '-------------------------------------------------');
    open sql_cur for
            vPLSQL;
    LOOP
        l_count := 0;
        l_object_code := null;
        i := i + 1;
        fetch sql_cur into l_count, l_object_code;
    exit when sql_cur%NOTFOUND;
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'OBJECT_CODE: ' || l_object_code || ' OBJECTS: ' || l_count);
        v_tot_objects := v_tot_objects + l_count ;
    end loop;
    close sql_cur;

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'TOTAL OBJECTS IN IEX_SCORE_HISTORIES BEFORE PURGE: ' || v_tot_objects);

    /* do erasing here */
    /* Removed by Andre 06/18/2004, we will need to delete in chunks
    EXECUTE IMMEDIATE v_del_sql ;
    */

     If NVL(p_truncate,'Y') <> 'N' then    -- fix a bug 5765878 to truncate table to perform better by Ehuh 2.19.2007
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Truncating Table => '||  p_truncate);
       v_del_sql := 'truncate table '||l_prod||'.IEX_SCORE_HISTORIES';  -- fix a bug 5765878 to truncate table to perform better by Ehuh 2.19.2007
       EXECUTE IMMEDIATE v_del_sql;

       --Start bug 8605501 gnramasa 20th Oct 09
       BEGIN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Table '||l_prod||'.IEX_SCORE_HISTORIES has been truncated, so will reset the Sequence '||l_prod||'.IEX_SCORE_HISTORIES_S value to 10000');
	EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_prod||'.IEX_SCORE_HISTORIES_S INCREMENT BY -1';
	EXECUTE IMMEDIATE 'select  '||l_prod||'.IEX_SCORE_HISTORIES_S.NEXTVAL +1 FROM DUAL' into v_num;
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Before altering Sequence '||l_prod||'.IEX_SCORE_HISTORIES_S value is: '|| v_num);

	if v_num <> 10000 then
	  EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_prod||'.IEX_SCORE_HISTORIES_S INCREMENT BY '|| ((v_num -10000)* -1);

	  EXECUTE IMMEDIATE 'select  '||l_prod||'.IEX_SCORE_HISTORIES_S.NEXTVAL FROM DUAL' into v_num;

	  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Sequence '||l_prod||'.IEX_SCORE_HISTORIES_S value is: 10000');
	else
	  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Sequence '||l_prod||'.IEX_SCORE_HISTORIES_S value is already 10000, so no need to change it again');
	end if;
	EXECUTE IMMEDIATE 'ALTER SEQUENCE '||l_prod||'.IEX_SCORE_HISTORIES_S INCREMENT BY 1';
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Sequence '||l_prod||'.IEX_SCORE_HISTORIES_S value is set to 10000');
	END;
       --End bug 8605501 gnramasa 20th Oct 09

    Else                                  -- fix a bug 5765878 to truncate table to perform better by Ehuh 2.19.2007

       if l_conditions.COUNT >= 1 then
          v_del_sql := v_del_sql || ' AND rownum >= 0 and rownum < ' || p_batch_size;
       else
          v_del_sql := v_del_sql || ' WHERE rownum >= 0 and rownum < ' || p_batch_size;
       end if;


       i := 0;
       vSelectCount := vSelectCount || vWhereClause;
       open sql_cur for vSelectCount;
       fetch sql_cur into vLoopCount;
       close sql_cur;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Final delete statement => '||  v_del_sql);
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Deleting => '||  vLoopCount || ' Records');

       loop
           EXECUTE IMMEDIATE v_del_sql;
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'i => '||  i );
           commit;

           i := i + p_batch_size;
           exit when i > vLoopCount;
       end loop;
       -- If we miss any because of the loop count...
       EXECUTE IMMEDIATE v_del_sql;
       commit;

   End if;   -- fix a bug 5765878 to truncate table to perform better by Ehuh 2.19.2007

   -- End changes, Andre 06/18/2004

    FND_FILE.PUT_LINE(FND_FILE.LOG, '-------------------------------------------------');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '                  AFTER PURGE');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '-------------------------------------------------');

    l_total := 0;
    open sql_cur for
            vPLSQL;
    LOOP
        l_count := 0;
        l_object_code := null;
        i := i + 1;
        fetch sql_cur into l_count, l_object_code;
    exit when sql_cur%NOTFOUND;
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'OBJECT_CODE: ' || l_object_code || ' OBJECTS: ' || l_count);
    end loop;
    close sql_cur;

    Begin
        Select Count(1) into l_total
          From IEX_SCORE_HISTORIES;
    Exception When NO_DATA_FOUND Then
        l_total := 0;
    END;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'TOTAL OBJECTS IN IEX_SCORE_HISTORIES AFTER PURGE: ' || l_total);

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.logMessage('IEX_SCORE: eraseScores: end time:'|| TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;
Exception
    WHEN FND_API.G_EXC_ERROR THEN
               RETCODE := -1;
               ERRBUF := l_msg_data;
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreConcur: Expected Error ' || sqlerrm );
               END IF;
               FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR IN CONCUR: ' || sqlerrm);

    WHEN OTHERS THEN
               RETCODE := -1;
               ERRBUF := l_msg_data;
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreConcur: Unexpected Error ' || sqlerrm);
               END IF;
               FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR IN CONCUR: ' || sqlerrm);
               --dbms_output.put_line(sqlerrm);

END eraseScores;

/*
|| Overview:    Returns an array of score values for a given objectID/Type
||
|| Parameter:    p_object_id   object scored in IEX_SCORE_HISTORIES required
||               p_object_code object_code in IEX_SCORE_HISTORIES required
||               p_from_Date  begin date restriction optional
||               p_to_date    end date restriction optional
||               p_scoreID     scoreEngineID used to score object optional
||
|| Return value:  SCORE_HISTORY_ID  -> PK to IEX_SCORE_HISTORIES
||                SCORE_ID          -> scoreEngine used to calculate score
||                SCORE_VALUE       -> score of object
||                CREATION_DATE     -> date object was scored
||
|| Source Tables:  IEX_SCORE_HISTORIES
||
|| Target Tables:  NA
||
|| Creation date:       04/22/2003 4:03PM
||
|| Major Modifications: when               who                      what
||                      04/22/2003 4:03PM  raverma               created
*/
function getScoreHistory (p_score_object_id    IN NUMBER,
                          p_score_object_code  IN VARCHAR2,
                          p_from_date    IN DATE ,
                          p_to_date      IN DATE ,
                          p_score_id     IN NUMBER ) return IEX_SCORE_NEW_PVT.SCORE_HISTORY_TBL
IS

  l_score_hist_tbl IEX_SCORE_NEW_PVT.SCORE_HISTORY_TBL;
  vPLSQL              VARCHAR2(200);
  l_total             NUMBER(38) ;
  i                   NUMBER     ;
  j                   NUMBER     ;
  l_object_code       VARCHAR2(50);
  Type refCur         is Ref Cursor;
  sql_cur             refCur;
  l_conditions        IEX_UTILITIES.Condition_Tbl;

  --clchang updated for sql bind var 05/07/2003
  vstr1   varchar2(100) ;
  vstr2   varchar2(100) ;
  vstr3   varchar2(100) ;
  vstr4   varchar2(100) ;
  vstr5   varchar2(100) ;
  vSqlCur varchar2(1000);

BEGIN
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScoreHistory: Start time:'|| TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;

    --clchang updated 10/29/04 no default values in declare
    l_total             := 0;
    i                   := 0;
    j                   := 0;
    vstr1   := 'SELECT SCORE_HISTORY_ID, ';
    vstr2   := '       SCORE_ID, ';
    vstr3   := '       SCORE_VALUE, ';
    vstr4   := '       CREATION_DATE ';
    vstr5   := ' FROM IEX_SCORE_HISTORIES ';

    /* build where clause */
    i:= i + 1;
    l_conditions(i).Col_Name := 'SCORE_OBJECT_ID';
    l_conditions(i).Condition := '=';
    l_conditions(i).Value := P_SCORE_OBJECT_ID;

    i := i + 1;
    l_conditions(i).Col_Name := 'SCORE_OBJECT_CODE';
    l_conditions(i).Condition := '=';
    l_conditions(i).Value := '''' || P_SCORE_OBJECT_CODE || '''';

    if P_FROM_DATE IS NOT NULL then
        i := i + 1;
        l_conditions(i).Col_Name := 'CREATION_DATE';
        l_conditions(i).Condition := '>';
        l_conditions(i).Value := '''' || to_char(P_FROM_DATE) || '''';
    end if;
    if P_TO_DATE IS NOT NULL then
        i := i + 1;
        l_conditions(i).Col_Name := 'CREATION_DATE';
        l_conditions(i).Condition := '<=';
        l_conditions(i).Value := '''' || to_char(P_TO_DATE) || '''';
    end if;
    if P_SCORE_ID IS NOT NULL then
        i := i + 1;
        l_conditions(i).Col_Name := 'SCORE_ID';
        l_conditions(i).Condition := '=';
        l_conditions(i).Value := P_SCORE_ID;
    end if;
    vPLSQL := IEX_UTILITIES.buildWhereClause(l_conditions);

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage(vPLSQL);
    END IF;
    --dbms_output.put_line(vPLSQL);

    /* execute history query and fetch */
    -- clchang updated for sql bind var 05/07/2003
    vSqlCur := vstr1 || vstr2 || vstr3 || vstr4 || vstr5 || vPLSQL;
    open sql_cur for vSqlCur;
    /*
    open sql_cur for
         'SELECT SCORE_HISTORY_ID, ' ||
         '       SCORE_ID, ' ||
         '       SCORE_VALUE, '||
         '       CREATION_DATE ' ||
         ' FROM IEX_SCORE_HISTORIES ' ||
            vPLSQL;
    */

    LOOP
        j := j + 1;
        fetch sql_cur into l_score_hist_tbl(j).Score_history_id,
                           l_score_hist_tbl(j).Score_id,
                           l_score_hist_tbl(j).score_value,
                           l_score_hist_tbl(j).creation_date;
    exit when sql_cur%NOTFOUND;
    end loop;
    close sql_cur;

    return l_score_hist_tbl;

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScoreHistory: end time:'|| TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;

Exception
    WHEN FND_API.G_EXC_ERROR THEN
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScoreHistory: Expected Error ' || sqlerrm );
       END IF;
       RETURN l_score_hist_tbl;

    WHEN OTHERS THEN
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScoreHistory: UnExpected Error ' || sqlerrm );
       END IF;
       RETURN l_score_hist_tbl;

END getScoreHistory;
--
--- Begin - Andre Araujo - 11/02/2004 - New storage mode, this one respects the commit size - TAR 4040621.994
--
/*
|| Overview:    Stores the score history given a table of records
||
|| Parameter:
||               p_scoreID     scoreEngineID used to score object optional
||
|| Return value:
||
|| Source Tables:  None
||
|| Target Tables:  IEX_SCORE_HISTORIES
||
|| Creation date:       11/02/2004
||
|| Major Modifications: when               who                      what
||
*/
procedure storeScoreHistory ( p_score_id     IN NUMBER default null,
			      p_objects_tbl  IN IEX_SCORE_NEW_PVT.SCORE_OBJECTS_TBL,
			      p_scores_tbl   IN IEX_SCORE_NEW_PVT.NEW_SCORES_TBL)
IS

    i                   NUMBER := 1;
    n                   NUMBER := 1;

    l_user              NUMBER;
    l_program           NUMBER;
    l_prog_appl         NUMBER;
    l_request           NUMBER;
    l_object_type       VARCHAR2(25);


BEGIN
	IF PG_DEBUG < 10  THEN
	  IEX_DEBUG_PUB.logMessage('IEX_SCORE: storeScoreHistory: Insert records!' );
	END IF;

        l_user      := FND_GLOBAL.USER_ID;
        l_request   := nvl(FND_GLOBAL.Conc_REQUEST_ID,0);
        l_program   := FND_GLOBAL.CONC_PROGRAM_ID;
        l_prog_appl := FND_GLOBAL.PROG_APPL_ID;

	IF p_scores_tbl.count > 0  THEN  -- Do we have records to store?
		IF PG_DEBUG < 10  THEN
		  IEX_DEBUG_PUB.logMessage('IEX_SCORE: storeScoreHistory: p_score_id= ' || p_score_id || ' ; Number of scores= ' || p_scores_tbl.count);
		END IF;

		-- initial variables needed
		select jtf_object_code into l_object_type
		  from iex_scores
		 where score_id = p_score_id;

		FORALL n in i..i + p_scores_tbl.count - 1
		insert into iex_score_histories(SCORE_HISTORY_ID
					      ,SCORE_OBJECT_ID
					      ,SCORE_OBJECT_CODE
					      ,OBJECT_VERSION_NUMBER
					      ,LAST_UPDATE_DATE
					      ,LAST_UPDATED_BY
					      ,LAST_UPDATE_LOGIN
					      ,CREATION_DATE
					      ,CREATED_BY
					      ,SCORE_VALUE
					      ,SCORE_ID
					      ,REQUEST_ID
					      ,PROGRAM_ID
					      ,PROGRAM_APPLICATION_ID
					      ,PROGRAM_UPDATE_DATE)
			   values(IEX_SCORE_HISTORIES_S.nextval
				  ,p_objects_tbl(n)
				  ,l_object_type
				  ,1
				  ,sysdate
				  ,l_user
				  ,l_user
				  ,sysdate
				  ,l_user
				  ,p_scores_tbl(n)
				  ,p_score_id
				  ,l_request
				  ,l_program
				  ,l_prog_appl
				  ,sysdate);

		IF PG_DEBUG < 10  THEN
		  IEX_DEBUG_PUB.logMessage('IEX_SCORE: storeScoreHistory: Commit records!' );
		END IF;

		commit;
	END IF; -- p_scores_tbl.count > 0

	IF PG_DEBUG < 10  THEN
	  IEX_DEBUG_PUB.logMessage('IEX_SCORE: storeScoreHistory: Return' );
	END IF;

Exception
    WHEN FND_API.G_EXC_ERROR THEN
       IF PG_DEBUG < 10  THEN
          IEX_DEBUG_PUB.logMessage('IEX_SCORE: storeScoreHistory: Expected Error ' || sqlerrm );
       END IF;
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR IN CONCUR: IEX_SCORE: storeScoreHistory:' || sqlerrm);

    WHEN OTHERS THEN
       IF PG_DEBUG < 10  THEN
          IEX_DEBUG_PUB.logMessage('IEX_SCORE: storeScoreHistory: UnExpected Error ' || sqlerrm );
       END IF;
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR IN CONCUR: IEX_SCORE: storeScoreHistory: UnExpected Error' || sqlerrm);

END storeScoreHistory;

/*
|| Overview:    Stores the score history given a table of records
||
|| Parameter:
||               p_scoreID     scoreEngineID used to score object optional
||
|| Return value:
||
|| Source Tables:  None
||
|| Target Tables:  IEX_SCORE_HISTORIES
||
|| Creation date:       11/02/2004
||
|| Major Modifications: when               who                      what
||
*/
procedure storeDelBuffers ( p_score_id     IN NUMBER default null,
			      p_objects_tbl  IN IEX_SCORE_NEW_PVT.SCORE_OBJECTS_TBL,
			      p_scores_tbl   IN IEX_SCORE_NEW_PVT.NEW_SCORES_TBL,
			      p_bridge       IN NUMBER default null)
IS
    i                   NUMBER := 1;
    n                   NUMBER := 1;

    l_user              NUMBER;
    l_program           NUMBER;
    l_prog_appl         NUMBER;
    l_request           NUMBER;
    l_object_type       VARCHAR2(25);
    l_bridge            NUMBER ;



BEGIN
	IF PG_DEBUG < 10  THEN
	  IEX_DEBUG_PUB.logMessage('IEX_SCORE: storeDelBuffers: Insert records!' );
	END IF;

    l_bridge             := p_bridge;
        l_user      := FND_GLOBAL.USER_ID;
        l_request   := nvl(FND_GLOBAL.Conc_REQUEST_ID,0);
        l_program   := FND_GLOBAL.CONC_PROGRAM_ID;
        l_prog_appl := FND_GLOBAL.PROG_APPL_ID;

	IF p_scores_tbl.count > 0  THEN  -- Do we have records to store?
		IF PG_DEBUG < 10  THEN
		  IEX_DEBUG_PUB.logMessage('IEX_SCORE: storeDelBuffers: p_score_id= ' || p_score_id || ' ; Number of scores= ' || p_scores_tbl.count);
		END IF;

		-- initial variables needed
		select jtf_object_code into l_object_type
		  from iex_scores
		 where score_id = p_score_id;


		FORALL n in i..i + p_scores_tbl.count - 1
		insert into IEX_DEL_BUFFERS(DEL_BUFFER_ID
					  ,SCORE_OBJECT_ID
					  ,SCORE_OBJECT_CODE
					  ,OBJECT_VERSION_NUMBER
					  ,LAST_UPDATE_DATE
					  ,LAST_UPDATED_BY
					  ,LAST_UPDATE_LOGIN
					  ,CREATION_DATE
					  ,CREATED_BY
					  ,SCORE_VALUE
					  ,SCORE_ID
					  ,REQUEST_ID
					  ,PROGRAM_ID
					  ,PROGRAM_APPLICATION_ID
					  ,PROGRAM_UPDATE_DATE)
			   values(IEX_DEL_BUFFERS_S.nextval
				  ,p_objects_tbl(n)
				  ,l_object_type
				  ,1
				  ,sysdate
				  ,l_user
				  ,l_user
				  ,sysdate
				  ,l_user
				  ,p_scores_tbl(n)
				  ,p_score_id
				  ,nvl(l_bridge,0)
				  ,l_program
				  ,l_prog_appl
				  ,sysdate);


		IF PG_DEBUG < 10  THEN
		  IEX_DEBUG_PUB.logMessage('IEX_SCORE: storeDelBuffers: Commit records!' );
		END IF;

		commit;
	END IF; -- p_scores_tbl.count > 0

	IF PG_DEBUG < 10  THEN
	  IEX_DEBUG_PUB.logMessage('IEX_SCORE: storeDelBuffers: Return' );
	END IF;

Exception
    WHEN FND_API.G_EXC_ERROR THEN
       IF PG_DEBUG < 10  THEN
          IEX_DEBUG_PUB.logMessage('IEX_SCORE: storeDelBuffers: Expected Error ' || sqlerrm );
       END IF;
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR IN CONCUR:IEX_SCORE: storeDelBuffers: Expected Error ' || sqlerrm);

    WHEN OTHERS THEN
       IF PG_DEBUG < 10  THEN
          IEX_DEBUG_PUB.logMessage('IEX_SCORE: storeDelBuffers: UnExpected Error ' || sqlerrm );
       END IF;
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR IN CONCUR:IEX_SCORE: storeDelBuffers: UnExpected Error ' || sqlerrm);

END storeDelBuffers;


/*
|| Overview:    Scores 1 item and returns the value
||
|| Parameter:
||               p_scoreID     scoreEngineID used to score object optional
||
|| Return value:
||
|| Source Tables:  None
||
|| Target Tables:  None
||
|| Creation date:       11/03/2004
||
|| Major Modifications: when               who                      what
||
*/
function get1Score ( p_score_comp_tbl IN IEX_SCORE_NEW_PVT.SCORE_ENG_COMP_TBL, p_object_id IN NUMBER ) return NUMBER
IS

    l_score_component_id  NUMBER;
    l_score_component_sql VARCHAR2(2500);
    l_execute_style       VARCHAR2(1);  -- are we using select or function call
    l_count2              number := 0;
    l_component_score     number := 0;
    type COMPONENT_RANGE is table of NUMBER
        index by binary_integer;
    l_component_range_tbl COMPONENT_RANGE;
    i			  NUMBER;
    l_raw_score           number := 0;
    l_running_score       number := 0;
    vSql                  varchar2(2500);
    l_value               VARCHAR2(2000);
    l_new_value           VARCHAR2(2000);
    l_weight_required     VARCHAR2(3);
    l_low                 varchar2(2000);
    l_high                varchar2(2000);
    l_rule                varchar2(20);
    --Begin Bug 8933776 30-Nov-2009 barathsr
    l_xml_body_1 varchar2(8000);
   -- l_new_line varchar2(1);
    l_jtf_obj_code  varchar2(50);
    l_party_name varchar2(360);
    l_object_id number;
    l_object_name varchar2(30);
    l_wtg_com_score number:=0;
    l_score_comp_name varchar2(300);
    l_score_comp_wtg number;
   --End Bug 8933776 30-Nov-2009 barathsr


BEGIN
	IF PG_DEBUG < 10  THEN
	  IEX_DEBUG_PUB.logMessage('IEX_SCORE: get1Score: Begin' );
	END IF;

--	 l_xml_body_1:=l_new_line||'<COMP_DET>';

-- copied code
            /* 3. for each component, execute SQL and get value */
            FOR l_count2 IN 1..p_score_comp_tbl.count LOOP
                l_score_component_id  := p_score_comp_tbl(l_count2).score_component_id;
                l_score_component_sql := p_score_comp_tbl(l_count2).SCORE_COMP_VALUE;
                l_execute_style       := p_score_comp_tbl(l_count2).function_flag;
                -- initialize this to the minimum for any given component
                --l_raw_score := IEX_SCORE_PVT.G_MIN_SCORE;
            --       FND_FILE.PUT_LINE(FND_FILE.LOG,'score_comp_cnt-->'||p_score_comp_tbl.count);
              --     FND_FILE.PUT_LINE(FND_FILE.LOG,'score_comp_val-->'|| p_score_comp_tbl(l_count2).SCORE_COMP_VALUE);
                --     FND_FILE.PUT_LINE(FND_FILE.LOG,'score_comp_id-->'|| p_score_comp_tbl(l_count2).score_component_id);


                if PG_DEBUG <= 5 then
                       IEX_DEBUG_PUB.logMessage('IEX_SCORE: get1Score: executing Component ' || l_count2 || ' CompID is: ' || l_score_component_id);
                       IEX_DEBUG_PUB.logMessage('IEX_SCORE: get1Score: Execute Stmt: ' || l_score_component_sql || ' Execute Style: ' || l_execute_style);
                       IEX_DEBUG_PUB.logMessage('IEX_SCORE: get1Score: Bind Variable: ' || p_object_id);
                end if;

                /* executing dynamic sql for component */
                --if l_score_component_sql is not null then
                    BEGIN

                     -- Execute SQL statement only when function syntax is not found
                     if l_execute_style = 'N' then
                        -- simple select statement
                        EXECUTE IMMEDIATE l_score_component_sql
                                INTO l_component_score
                                USING p_object_id;
                     else
                        -- function to execute
                        -- to do - pass the score component id for Function calls only
                        EXECUTE IMMEDIATE l_score_component_sql
                                   USING in p_object_id,
                                         in l_score_component_id,
                                         out l_component_score;
                     end if;

                    EXCEPTION

                        -- assign the "Lowest" Detail for the component
                        -- in order to do this we must know what is "high" and "low" range of component

                        WHEN OTHERS THEN
                        -- Begin - Andre Araujo - 12/17/2004 - If the detail is not defined this throws a NO DATA FOUND
                        Begin
                        -- End - Andre Araujo - 12/17/2004 - If the detail is not defined this throws a NO DATA FOUND
                            -- figure out whether the component details are better higher or worse higher
                            IF PG_DEBUG <= 5  THEN
                               IEX_DEBUG_PUB.logMessage('IEX_SCORE: get1Score: Failed to calculate for component ' || l_score_component_id );
                               IEX_DEBUG_PUB.logMessage('Reason: ' || sqlerrm);
                            END IF;

                            SELECT Range_Low
                            BULK COLLECT INTO l_component_range_tbl
                              FROM iex_score_comp_det
                             where score_component_id = l_score_component_id
                            order by value;

                            IF PG_DEBUG <= 5  THEN
                                IEX_DEBUG_PUB.logMessage('Comparing Ranges');
                            END IF;

                            if l_component_range_tbl(1) < l_component_range_tbl(2) then
                                -- assign first comnponent detail row range to value
                                l_component_score := l_component_range_tbl(1);
                            else
                                -- assign last comnponent detail row range to value
                                i := l_component_range_tbl.count;
                                l_component_score := l_component_range_tbl(i);
                            end if;
                            l_component_range_tbl.delete;
                            -- Begin - Andre Araujo - 12/17/2004 - If the detail is not defined this throws a NO DATA FOUND
                            EXCEPTION
                               WHEN OTHERS THEN -- This will capture the exception from the component detail
                                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'IEX_SCORE: get1Score: Exception selecting component detail range: WRONG ENGINE CONFIGURATION!!!!!');
                                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'IEX_SCORE: get1Score: Score will be 1 - Execution will continue.');
                                  l_component_score := 1;
                            END;
                            -- End - Andre Araujo - 12/17/2004 - If the detail is not defined this throws a NO DATA FOUND
                    END; -- end for exception

                  if PG_DEBUG <= 5 then
                        IEX_DEBUG_PUB.logMessage('IEX_SCORE: get1Score: Successfully calculated component score: ' || l_component_score);
                  end if;


		/*  exception
	        WHEN NO_DATA_FOUND THEN
                        IF PG_DEBUG < 10  THEN
                           IEX_DEBUG_PUB.logMessage('IEX_SCORE: get1Score: Error in getting tag details for report: ' || sqlerrm);
                        END IF;

                    WHEN OTHERS THEN
                        IF PG_DEBUG < 10  THEN
                           IEX_DEBUG_PUB.logMessage('IEX_SCORE: get1Score: Error in getting tag details for report: ' || sqlerrm);
                        END IF;

             END; */


                --end if;
		--Begin Bug 8933776 30-Nov-2009 barathsr
                l_xml_body_1:=l_new_line||'<COMP_VAL>';
		l_xml_body_1:=l_xml_body_1||l_new_line||'<SCORE_COMP_ID>'||l_score_component_id||'</SCORE_COMP_ID>';
		begin
		select sctl.score_comp_name,sc.score_comp_weight
		into l_score_comp_name,l_score_comp_wtg
		from iex_score_components sc, iex_score_comp_types_tl sctl
		where sc.score_comp_type_id=sctl.score_comp_type_id
		and sc.score_component_id=l_score_component_id
		and sctl.language='US';
                l_xml_body_1:=l_xml_body_1||l_new_line||'<SCORE_COMP_NAME>'||format_string(l_score_comp_name)||'</SCORE_COMP_NAME>';
		l_xml_body_1:=l_xml_body_1||l_new_line||'<COMP_SCORE>'||l_component_score||'</COMP_SCORE>';
                l_xml_body_1:=l_xml_body_1||l_new_line||'<COMP_WGT>'||l_score_comp_wtg||'</COMP_WGT>';
		 exception
	          when others then
		    FND_FILE.PUT_LINE(FND_FILE.LOG, 'error in get1score in getting score component details'||sqlerrm);
		   IEX_DEBUG_PUB.logMessage('error in get1score in getting score component details'||sqlerrm);
		 end;
               --End Bug 8933776 30-Nov-2009 barathsr
            /* 4. For each component value, get the details of the component
            and store the value for that score_comp_detail */
             BEGIN
                -- clchang updated 10/18/04 for 11.5.11
                -- new column NEW_VALUE instead of VALUE in iex_score_comp_det;
                --vSql := 'SELECT VALUE ' ||
                vSql := 'SELECT upper(NEW_VALUE) ' ||
                      '  FROM IEX_SCORE_COMP_DET ' ||
                      ' WHERE SCORE_COMPONENT_ID = :p_score_comp_id AND ' ||
                      '       :p_component_score >= RANGE_LOW AND ' ||
                      '       :p_component_score <= RANGE_HIGH  ';
                if PG_DEBUG <= 5 then
                     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                     IEX_DEBUG_PUB.logMessage('IEX_SCORE: get1Score: ' || 'Getting Details for component with ' || vSQL);
                     END IF;
                end if;

                -- clchang updated 10/18/04 for 11.5.11
                -- the value from det could be formula (including bind var :result);
                Execute Immediate vSql
                  --INTO l_raw_score
                  INTO l_value
                  USING l_score_component_id, l_component_score, l_component_score;

                --IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                --IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: Component raw score is ' || l_raw_score || ' Component weight is ' || l_score_comp_tbl(l_count2).SCORE_COMP_WEIGHT);
                --END IF;

		   -- BEGIN clchang added 10/18/04 for scr engine enhancement in 11.5.11

		  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		      IEX_DEBUG_PUB.logMessage('IEX_SCORE: get1Score: l_value=' || l_value);
		  END IF;
		  -- chk the value is a formula or not
		  IF (INSTR(l_value, ':RESULT') > 0 ) THEN
		    l_new_value := replace(l_value, ':RESULT', l_component_score);
		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		      IEX_DEBUG_PUB.logMessage('IEX_SCORE: get1Score: FORMULA');
		      IEX_DEBUG_PUB.logMessage('IEX_SCORE: get1Score: l_new_value=' || l_new_value);
		    END IF;
		    vSql := 'SELECT ' || l_new_value || ' FROM DUAL';
		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		      IEX_DEBUG_PUB.logMessage('IEX_SCORE: get1Score: vSql=' || vSql);
		    END IF;
		    Execute Immediate vSql
		       INTO l_raw_score;
		  ELSE
		    l_raw_score := TO_NUMBER( l_value);
		  END IF;
		  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		    IEX_DEBUG_PUB.logMessage('IEX_SCORE: get1Score: l_raw_score=' || l_raw_score);
		  END IF;

                 l_xml_body_1:=l_xml_body_1||l_new_line||'<RAW_SCORE>'||l_raw_score||'</RAW_SCORE>';--Added for Bug 8933776 30-Nov-2009 barathsr

		  l_weight_required := IEX_SCORE_NEW_PVT.G_WEIGHT_REQUIRED;

		  -- if weight_required <> Y, sum(score of each comp);
		  IF (l_weight_required = 'Y') THEN
		      --l_running_score:=l_running_score + round((l_raw_score * l_score_comp_tbl(l_count2).SCORE_COMP_WEIGHT));
		      l_wtg_com_score:=round((l_raw_score * p_score_comp_tbl(l_count2).SCORE_COMP_WEIGHT),2);
		      l_running_score:=l_running_score + round((l_raw_score * p_score_comp_tbl(l_count2).SCORE_COMP_WEIGHT),2);
		  ELSE
		      --l_running_score:=l_running_score + round(l_raw_score );
		      l_wtg_com_score:=round(l_raw_score );
		      l_running_score:=l_running_score + round(l_raw_score,2 );
		  END IF;
		  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		    IEX_DEBUG_PUB.logMessage('IEX_SCORE: get1Score: l_running_score=' || l_running_score);
		  END IF;
                  --Begin Bug 8933776 30-Nov-2009 barathsr
		   l_xml_body_1:=l_xml_body_1||l_new_line||'<WEIGHTED_COMP_SCORE>'||l_wtg_com_score||'</WEIGHTED_COMP_SCORE>';
		   l_xml_body_1:=l_xml_body_1||l_new_line||'</COMP_VAL>';
		 dbms_lob.writeAppend(tempResult, length(l_xml_body_1), l_xml_body_1);
		  --End Bug 8933776 30-Nov-2009 barathsr

	--	   FND_FILE.put_line( FND_FILE.LOG,'*****end of score details************');

		  -- END clchang added 10/18/04 for scr engine enhancement in 11.5.11

                --l_running_score:=l_running_score + round((l_raw_score * p_score_comp_tbl(l_count2).SCORE_COMP_WEIGHT));
                --IEX_DEBUG_PUB.logMessage('IEX_SCORE: getScores: Component Running score is ' || l_running_score);

             EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        IF PG_DEBUG < 10  THEN
                           IEX_DEBUG_PUB.logMessage('IEX_SCORE: get1Score: Error getting component detail: ' || sqlerrm);
                        END IF;
                        l_running_score := l_running_score;
                    WHEN OTHERS THEN
                        IF PG_DEBUG < 10  THEN
                           IEX_DEBUG_PUB.logMessage('IEX_SCORE: get1Score: Error getting component detail: ' || sqlerrm);
                        END IF;
                        l_running_score := l_running_score;
             END;

            END LOOP; -- component loop



-- End copied code

	IF PG_DEBUG < 10  THEN
	  IEX_DEBUG_PUB.logMessage('IEX_SCORE: get1Score: Return calculated score: ' || l_running_score );
	END IF;

	return l_running_score;

Exception
    WHEN FND_API.G_EXC_ERROR THEN
       IF PG_DEBUG < 10  THEN
          IEX_DEBUG_PUB.logMessage('IEX_SCORE: get1Score: Expected Error ' || sqlerrm );
       END IF;
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR IN CONCUR:IEX_SCORE: get1Score: Expected Error ' || sqlerrm);

    WHEN OTHERS THEN
       IF PG_DEBUG < 10  THEN
          IEX_DEBUG_PUB.logMessage('IEX_SCORE: get1Score: UnExpected Error ' || sqlerrm );
       END IF;
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR IN CONCUR:IEX_SCORE: get1Score: UnExpected Error ' || sqlerrm);

END get1Score;

--
--- End - Andre Araujo - 11/02/2004 - New storage mode, this one respects the commit size - TAR 4040621.994
--

--procedure gen_xml_hdr


BEGIN
  G_Batch_Size   := to_number(nvl(fnd_profile.value('IEX_BATCH_SIZE'), '1000'));
  PG_DEBUG  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  G_MIN_SCORE         := '1';
  G_MAX_SCORE         := '100';
  G_RULE              := 'CLOSEST';
  G_WEIGHT_REQUIRED   := 'N';


END IEX_SCORE_NEW_PVT;

/
