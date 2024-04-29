--------------------------------------------------------
--  DDL for Package Body JTY_WEBADI_OTH_TERR_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTY_WEBADI_OTH_TERR_UPDATE_PKG" AS
/* $Header: jtfowupb.pls 120.42.12010000.27 2010/04/05 09:30:33 vpalle ship $ */

--    Start of Comments

--    ---------------------------------------------------

--    PACKAGE NAME:   JTY_WEBADI_OTH_TERR_UPDATE_PKG

--    ---------------------------------------------------



--  PURPOSE

--      upload other territories information from excel

--

--

--  PROCEDURES:

--       (see below for specification)

--

--

--  HISTORY

--    09/01/2005  mhtran          Package Body Created
--	  02/03/2005  MHTRAN		  Modified
--

--    End of Comments

--


  TYPE number_tbl_type is table of NUMBER index by PLS_INTEGER;
  TYPE varchar2_tbl_type is table of VARCHAR2(360) index by PLS_INTEGER;
  TYPE date_tbl_type is table of DATE index by PLS_INTEGER;
  TYPE var_1_tbl_type is table of VARCHAR2(1) index by PLS_INTEGER;
  TYPE var_2000_tbl_type is table of VARCHAR2(2000) index by PLS_INTEGER;

  TYPE Terr_Values_Rec_Type  IS RECORD
   (TERR_VALUE_ID                    number_tbl_type,
    LAST_UPDATE_DATE                 date_tbl_type,
    LAST_UPDATED_BY                  number_tbl_type,
    CREATION_DATE                    date_tbl_type,
    CREATED_BY                       number_tbl_type,
    LAST_UPDATE_LOGIN                number_tbl_type,
    TERR_QUAL_ID                     number_tbl_type,
    COMPARISON_OPERATOR              varchar2_tbl_type,
    LOW_VALUE_CHAR                   varchar2_tbl_type,
    HIGH_VALUE_CHAR                  varchar2_tbl_type,
    LOW_VALUE_NUMBER                 number_tbl_type,
    HIGH_VALUE_NUMBER                number_tbl_type,
    INTEREST_TYPE_ID                 number_tbl_type,
    PRIMARY_INTEREST_CODE_ID         number_tbl_type,
    SECONDARY_INTEREST_CODE_ID       number_tbl_type,
    CURRENCY_CODE                    varchar2_tbl_type,
    ID_USED_FLAG                     var_1_tbl_type,
    LOW_VALUE_CHAR_ID                number_tbl_type,
    ORG_ID                           number_tbl_type,
    VALUE1_ID                        number_tbl_type,
    VALUE2_ID                        number_tbl_type,
    VALUE3_ID                        number_tbl_type
   );

  TYPE Terr_Qual_Rec_Type  IS RECORD
    (  CONVERT_TO_ID_FLAG			 var_1_tbl_type,
       TERR_QUAL_ID                  number_tbl_type,
	   qual_value_id				 number_tbl_type,
	   qual_value1					 varchar2_tbl_type,
	   qual_value2					 varchar2_tbl_type,
	   qual_value3					 varchar2_tbl_type,
	   qualifier_num				 number_tbl_type,
	   html_lov_sql1				 var_2000_tbl_type,
	   qual_cond					 varchar2_tbl_type,
	   qual_type					 varchar2_tbl_type,
       LAST_UPDATE_DATE              date_tbl_type,
       LAST_UPDATED_BY               number_tbl_type,
       CREATION_DATE                 date_tbl_type,
       CREATED_BY                    number_tbl_type,
       LAST_UPDATE_LOGIN             number_tbl_type,
       TERR_ID                       number_tbl_type,
       QUAL_USG_ID                   number_tbl_type,
       ORG_ID                        number_tbl_type
     );

  TYPE Terr_values_out_rec_type IS RECORD
    (  TERR_VALUE_ID                 number_tbl_type,
       TERR_QUAL_ID                  number_tbl_type
	);

PROCEDURE debugmsg(msg VARCHAR2) IS
  BEGIN
    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'jtf.plsql.JTY_WEBADI_OTH_TERR_UPDATE_PKG', msg);
    end if;
END debugmsg;

PROCEDURE get_hierarchy
  ( p_user_sequence  IN  number,
        p_intf_type                 IN  varchar2 default 'U',
        x_return_status         out nocopy varchar2,
        x_msg_data                 out nocopy varchar2
)
IS

  cursor get_hierarchy_csr
  ( v_user_sequence number,
        v_intf_type                varchar2) IS
    SELECT TERR_NAME, trim(HIERARCHY) hierarchy, ORG_ID, org_name
        FROM JTY_WEBADI_OTH_TERR_INTF
        where user_sequence = v_user_sequence
          and interface_type = v_intf_type
          and header = 'TERR'
          and lay_seq_num is not null
          and status is null;

        type get_hierarchy_type is TABLE of get_hierarchy_csr%rowtype INDEX BY PLS_INTEGER;

        l_hierarchy_tbl get_hierarchy_type;
        l_parent_id                 number;
        l_anc_id                number;
        l_instr                         number;
        l_count                         number;
        l_terr                         varchar2(2000);
        l_parent                varchar2(2000);
        l_return_csr            NUMBER;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
 /*
  update JTY_WEBADI_OTH_TERR_INTF
  set parent_terr_id = null
  where user_sequence = p_user_sequence
    and interface_type = p_intf_type
        and hierarchy is null;
  */
  --dbms_output.put_line('Start hierarchy');
  -- get parent_id from hierarchy columns
  open get_hierarchy_csr(p_user_sequence, p_intf_type);
  fetch get_hierarchy_csr bulk collect into l_hierarchy_tbl;
  close get_hierarchy_csr;

  if l_hierarchy_tbl.count > 0 then
  for c in l_hierarchy_tbl.first..l_hierarchy_tbl.last loop
          l_parent_id := 1;
          l_anc_id := 1;

    if l_hierarchy_tbl(c).hierarchy is null then
          -- no hierarchy found. Root node
          l_parent := l_hierarchy_tbl(c).org_name;

          update JTY_WEBADI_OTH_TERR_INTF
          set parent_terr_id = l_parent_id
          , parent_terr_name = l_parent
          where terr_name = l_hierarchy_tbl(c).terr_name
          and user_sequence = p_user_sequence
          and interface_type = p_intf_type;

    --dbms_output.put_line('hierarchy updated');

    else
          l_terr := l_hierarchy_tbl(c).hierarchy;
      l_instr := instr(l_terr,'->');
          --dbms_output.put_line('l_instr,l_terr: '||l_instr||','||l_terr);
        loop
          if l_instr = 0 then
            l_parent := l_terr;
            --dbms_output.put_line('l_instr = 0, l_parent: '||l_parent);

                  select count(*) into l_count
                  from jtf_terr_all
                  where name = l_parent
                and parent_territory_id = l_anc_id
                and org_id = l_hierarchy_tbl(c).org_id;

                case l_count
                when 0 then
    -- If this is a new heirarchy, setting its parent to CATCH ALL intially and updating it later to correct parent (populate_parent_id).
              update JTY_WEBADI_OTH_TERR_INTF
                  set parent_terr_id = 1
                    , parent_terr_name = l_parent
                  where terr_name = l_hierarchy_tbl(c).terr_name
                  and user_sequence = p_user_sequence
                  and interface_type = p_intf_type;
                when 1 then
                  -- lowest level parent_id found, update interface table
              select terr_id into l_parent_id
                  from jtf_terr_all
                  where org_id = l_hierarchy_tbl(c).org_id
              and name = l_parent
                  and parent_territory_id = l_anc_id;

                 -- Update mode only: Top down checking if new parent territory is already a child of the current territory
                 -- This fix is to avoid error ORA-01436: CONNECT BY loop in user data
                BEGIN
                 SELECT COUNT(*)
                 INTO l_return_csr
                 FROM JTY_WEBADI_OTH_TERR_INTF j
                 WHERE j.terr_id = l_parent_id  -- new parent territory id
                 AND user_sequence = p_user_sequence
                 and interface_type = p_intf_type
                 and action_flag = 'U' --  Update mode
                 CONNECT BY PRIOR j.terr_id = j.parent_terr_id
                 START WITH j.terr_name = l_hierarchy_tbl(c).terr_name; -- territory_id

                  IF (l_return_csr = 0 )THEN
                    update JTY_WEBADI_OTH_TERR_INTF
                    set parent_terr_id = l_parent_id
                        , parent_terr_name = l_parent
                    where terr_name = l_hierarchy_tbl(c).terr_name
                    and user_sequence = p_user_sequence
                    and interface_type = p_intf_type;

                  ELSE
                    x_return_status := fnd_api.g_ret_sts_error;
                    fnd_message.clear;
                    fnd_message.set_name('JTF', 'JTY_OTH_TERR_CIR_REF');
                    x_msg_data := fnd_message.GET();

                    UPDATE jty_webadi_oth_terr_intf
                    SET status = x_return_status,
                      error_msg = x_msg_data
                    WHERE terr_name = l_hierarchy_tbl(c).terr_name
                    AND user_sequence = p_user_sequence
                    AND interface_type = p_intf_type;
                  END IF;
                EXCEPTION WHEN OTHERS THEN
                  IF SQLCODE = -01436 THEN
                    x_return_status := fnd_api.g_ret_sts_error;
                    fnd_message.clear;
                    fnd_message.set_name('JTF', 'JTY_OTH_TERR_CIR_REF');
                    x_msg_data := fnd_message.GET();

                    UPDATE jty_webadi_oth_terr_intf
                    SET status = x_return_status,
                      error_msg = x_msg_data
                    WHERE terr_name = l_hierarchy_tbl(c).terr_name
                    AND user_sequence = p_user_sequence
                    AND interface_type = p_intf_type;
                  END IF;
                END;

                else
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  fnd_message.clear;
                  FND_MESSAGE.set_name ('JTF', 'JTY_OTH_TERR_NON_UNIQUE_TERR');
                  FND_MESSAGE.set_token ('POSITION', l_parent);
                  X_Msg_Data := fnd_message.get();
              update JTY_WEBADI_OTH_TERR_INTF
                  set status = x_return_status
                  , error_msg = X_Msg_Data
                  where terr_name = l_hierarchy_tbl(c).terr_name
                  and user_sequence = p_user_sequence
                  and interface_type = p_intf_type;
                end case;
                EXIT;
          else
        l_parent := substr(l_terr,1,l_instr -1);
            --dbms_output.put_line('l_parent: '||l_parent);

                  select count(*) into l_count
                  from jtf_terr_all
                  where name = l_parent
                and parent_territory_id = l_anc_id
                and org_id = l_hierarchy_tbl(c).org_id;

                case l_count
                when 0 then
                  l_parent := substr(l_terr,instr(l_terr,'->',-1)+2);
            --dbms_output.put_line('case 0, l_parent: '||l_parent);
      -- If this is a new heirarchy, setting its parent to CATCH ALL intially and updating it later to correct parent (populate_parent_id).
            update JTY_WEBADI_OTH_TERR_INTF
                  set parent_terr_id = 1
                    , parent_terr_name = l_parent
                  where terr_name = l_hierarchy_tbl(c).terr_name
                  and user_sequence = p_user_sequence
                  and interface_type = p_intf_type;
                  exit;
                when 1 then
              select terr_id into l_parent_id
                  from jtf_terr_all
                  where org_id = l_hierarchy_tbl(c).org_id
              and name = l_parent
                  and parent_territory_id = l_anc_id;
                else
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  fnd_message.clear;
                  FND_MESSAGE.set_name ('JTF', 'JTY_OTH_TERR_NON_UNIQUE_TERR');
                  FND_MESSAGE.set_token ('POSITION', l_parent);
                  X_Msg_Data := fnd_message.get();

              update JTY_WEBADI_OTH_TERR_INTF
                  set status = x_return_status
                  , error_msg = X_Msg_Data
                  where terr_name = l_hierarchy_tbl(c).terr_name
                  and user_sequence = p_user_sequence
                  and interface_type = p_intf_type;
                  exit;
                end case;

                l_anc_id := l_parent_id;
        l_terr := substr(l_terr, l_instr+2);
            l_instr := instr(l_terr, '->');

            --dbms_output.put_line('l_instr, l_terr, l_parent, l_anc_id: '||l_instr||', '||l_terr||', '||l_parent||', '||l_anc_id);

          END IF; -- instr = 0
        end loop; -- loop through instr
        end if; -- hierarchy is null

  end loop;
  end if;

  exception
    when others then
          x_return_status := FND_API.G_RET_STS_ERROR;
end get_hierarchy;

--  This procedure populates the parent terr id when new territory heirarchy is being created.

PROCEDURE populate_parent_id(
                  p_user_sequence IN NUMBER,
                  p_intf_type IN VARCHAR2 DEFAULT 'U',
                  p_hierarchy IN VARCHAR2,
                  p_org_id IN NUMBER,
                  p_terr_id IN NUMBER,
                  p_terr_name IN VARCHAR2,
                  x_return_status OUT nocopy VARCHAR2,
                  x_msg_data OUT nocopy VARCHAR2 )

IS
  l_parent_id NUMBER;
  l_anc_id NUMBER;
  l_instr NUMBER;
  l_count NUMBER;
  l_terr VARCHAR2(2000);
  l_parent VARCHAR2(2000);
  l_return_csr               NUMBER;

BEGIN

  x_return_status := fnd_api.g_ret_sts_success;

  l_parent_id := 1;
  l_anc_id := 1;
  l_terr := p_hierarchy;
  l_instr := instr(l_terr,   '->');
  --dbms_output.put_line('l_instr,l_terr: '||l_instr||','||l_terr);
  LOOP

    IF l_instr = 0 THEN
      l_parent := l_terr;
      --dbms_output.put_line('l_instr = 0, l_parent: '||l_parent);

      SELECT COUNT(*)
      INTO l_count
      FROM jtf_terr_all
      WHERE name = l_parent
       AND parent_territory_id = l_anc_id
       AND org_id = p_org_id;

      IF (l_count = 1 OR l_count = 0 ) THEN
        -- lowest level parent_id found, update interface table
        SELECT terr_id
        INTO l_parent_id
        FROM jtf_terr_all
        WHERE org_id = p_org_id
         AND name = l_parent
         AND parent_territory_id = l_anc_id;

       -- Top down checking if new parent territory is already a child of the current territory
       -- This fix is to avoid error ORA-01436: CONNECT BY loop in user data
       BEGIN
         SELECT COUNT(*)
         INTO l_return_csr
         FROM jtf_terr_all j
         WHERE j.terr_id = l_parent_id  -- new parent territory id
         CONNECT BY PRIOR j.terr_id = j.parent_territory_id
         START WITH j.terr_id = p_terr_id; -- territory_id

         IF (l_return_csr = 0 )THEN
            UPDATE jtf_terr_all
            SET parent_territory_id = l_parent_id
            WHERE terr_id = p_terr_id;
         ELSE
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_message.clear;
            fnd_message.set_name('JTF', 'JTY_OTH_TERR_CIR_REF');
            x_msg_data := fnd_message.GET();

            UPDATE jty_webadi_oth_terr_intf
            SET status = x_return_status,
              error_msg = x_msg_data
            WHERE terr_name = p_terr_name
            AND user_sequence = p_user_sequence
            AND interface_type = p_intf_type;
         END IF;
       EXCEPTION WHEN OTHERS THEN
        IF SQLCODE = -01436 THEN
          x_return_status := fnd_api.g_ret_sts_error;
          fnd_message.clear;
          fnd_message.set_name('JTF', 'JTY_OTH_TERR_CIR_REF');
          x_msg_data := fnd_message.GET();

          UPDATE jty_webadi_oth_terr_intf
            SET status = x_return_status,
            error_msg = x_msg_data
          WHERE terr_name =  p_terr_name
          AND user_sequence = p_user_sequence
          AND interface_type = p_intf_type;
        END IF;
      END;

      ELSE
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_message.clear;
        fnd_message.set_name('JTF',   'JTY_OTH_TERR_NON_UNIQUE_TERR');
        fnd_message.set_token('POSITION',   l_parent);
        x_msg_data := fnd_message.GET();

        UPDATE jty_webadi_oth_terr_intf
        SET status = x_return_status,
          error_msg = x_msg_data
        WHERE terr_name = p_terr_name
         AND user_sequence = p_user_sequence
         AND interface_type = p_intf_type;

      END IF;
      EXIT;

    ELSE
      l_parent := SUBSTR(l_terr,   1,   l_instr -1);
      --dbms_output.put_line('l_parent: '||l_parent);

      SELECT COUNT(*)
      INTO l_count
      FROM jtf_terr_all
      WHERE name = l_parent
       AND parent_territory_id = l_anc_id
       AND org_id = p_org_id;

      IF l_count = 1 THEN
        SELECT terr_id
        INTO l_parent_id
        FROM jtf_terr_all
        WHERE org_id = p_org_id
         AND name = l_parent
         AND parent_territory_id = l_anc_id;

        --Bug 9204941
      ELSIF l_count = 0 THEN

       SELECT terr_id
        INTO l_parent_id
        FROM jty_webadi_oth_terr_intf
        WHERE org_id = p_org_id
         AND terr_name = l_parent
         AND parent_terr_id = l_anc_id;

      ELSE
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_message.clear;
        fnd_message.set_name('JTF',   'JTY_OTH_TERR_NON_UNIQUE_TERR');
        fnd_message.set_token('POSITION',   l_parent);
        x_msg_data := fnd_message.GET();

        UPDATE jty_webadi_oth_terr_intf
        SET status = x_return_status,
          error_msg = x_msg_data
        WHERE terr_name = p_terr_name
         AND user_sequence = p_user_sequence
         AND interface_type = p_intf_type;

        EXIT;

      END IF;

      l_anc_id := l_parent_id;
      l_terr := SUBSTR(l_terr,   l_instr + 2);
      l_instr := instr(l_terr,   '->');
    END IF;

    -- instr = 0
  END LOOP;

  -- loop through instr

  EXCEPTION
  WHEN others THEN
    x_return_status := fnd_api.g_ret_sts_error;
  END populate_parent_id;

PROCEDURE VALIDATE_TERRITORY_RECORDS
(  P_USER_SEQUENCE		   IN NUMBER,
   P_INTF_TYPE			   IN VARCHAR2,
   X_RETURN_STATUS		   OUT NOCOPY VARCHAR2,
   X_MSG_DATA			   OUT NOCOPY VARCHAR2
) IS
  l_action_flag varchar2(1) := 'U';
  l_header		varchar2(15);
  l_count		number;

  CURSOR get_qual_csr(
    v_user_sequence number,
    v_intf_type	  varchar2,
    v_header		  varchar2) IS
	select jqh.qualifier_name, sub.lay_seq_num
	from JTY_WEBADI_QUAL_HEADER jqh,
	(
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      1 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual1_value1 is not null
      and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      2 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual2_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      3 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual3_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      4 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual4_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      5 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual5_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      6 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual6_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      7 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual7_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      8 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual8_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      9 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual9_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      10 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual10_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      11 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual11_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      12 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual12_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      13 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual13_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      14 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual14_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      15 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual15_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      16 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual16_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      17 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual17_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      18 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual18_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      19 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual19_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      20 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual20_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      21 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual21_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      22 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual22_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      23 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual23_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      24 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual24_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      25 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual25_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
	  union all
	  select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      26 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual26_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      27 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual27_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      28 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual28_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      29 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual29_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      30 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual30_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      31 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual31_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      32 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual32_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      33 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual33_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      34 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual34_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      35 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual35_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      36 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual36_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      37 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual37_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      38 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual38_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      39 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual39_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      40 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual40_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      41 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual41_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      42 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual42_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      43 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual43_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      44 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual44_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      45 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual45_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
	  union all
	  select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      46 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual46_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      47 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual47_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      48 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual48_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      49 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual49_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      50 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual50_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      51 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual51_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      52 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual52_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      53 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual53_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      54 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual54_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      55 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual55_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      56 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual56_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      57 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual57_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      58 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual58_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      59 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual59_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      60 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual60_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      61 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual61_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      62 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual62_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      63 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual63_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      64 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual64_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      65 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual65_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
	  union all
	  select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      66 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual46_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      67 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual67_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      68 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual68_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      69 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual69_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      70 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual70_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      71 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual71_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      72 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual72_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      73 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual73_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      74 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual74_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select jut.lay_seq_num, jut.user_sequence, jut.terr_type_id,
      75 qual_num
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.qual75_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header ) sub
	  where jqh.qualifier_num = sub.qual_num
	    and jqh.user_sequence = sub.user_sequence
	    and not exists (select 1 from jtf_terr_type_qual_all jttq
					   	   where jttq.terr_type_id = sub.terr_type_id
						     and jttq.qual_usg_id = jqh.qual_usg_id);

  TYPE Qual_Rec_Type  IS RECORD
    (  lay_seq_num				 number_tbl_type,
	   qualifier_name				 varchar2_tbl_type );

  qual_rec 	Qual_Rec_Type;
BEGIN
  debugmsg('VALIDATE_TERRITORY_RECORDS: P_USER_SEQUENCE : ' || P_USER_SEQUENCE);
  debugmsg('VALIDATE_TERRITORY_RECORDS: P_INTF_TYPE : ' || P_INTF_TYPE);
  x_return_status := FND_API.G_RET_STS_ERROR;
  fnd_message.clear;
  fnd_message.set_name ('JTF', 'JTF_TTY_INVALID_TERR_NAME');
  X_Msg_Data := fnd_message.get();
  debugmsg('VALIDATE_TERRITORY_RECORDS: Validate JTF_TTY_INVALID_TERR_NAME : ' );
 	update JTY_WEBADI_OTH_TERR_INTF jwot
	set status = x_return_status,
	error_msg = X_Msg_Data
	where jwot.terr_name is null
	  and jwot.USER_SEQUENCE = p_USER_SEQUENCE
	  and jwot.INTERFACE_TYPE = p_intf_type
	  and jwot.status is null;

  -- Fix for bug 8289489. Rank can't be null. This fix can be removed, if webadi raises error for not null columns.
  x_return_status := FND_API.G_RET_STS_ERROR;
  fnd_message.clear;
  fnd_message.set_name ('JTF', 'JTY_OTH_TERR_INVALID_RANK');
  X_Msg_Data := fnd_message.get();

 	update JTY_WEBADI_OTH_TERR_INTF jwot
	set status = x_return_status,
	error_msg = X_Msg_Data
	where jwot.rank is null
          and jwot.header = 'TERR'
	  and jwot.USER_SEQUENCE = p_USER_SEQUENCE
	  and jwot.INTERFACE_TYPE = p_intf_type
	  and jwot.status is null;

  -- Fix for bug 8289489. ORG ID can't be null. This fix can be removed, if webadi raises error for not null columns.
  x_return_status := FND_API.G_RET_STS_ERROR;
  fnd_message.clear;
  fnd_message.set_name ('JTF', 'JTY_OTH_TERR_INVALID_ORGID');
  X_Msg_Data := fnd_message.get();

 	update JTY_WEBADI_OTH_TERR_INTF jwot
	set status = x_return_status,
	error_msg = X_Msg_Data
	where jwot.org_id is null
          and jwot.header = 'TERR'
	  and jwot.USER_SEQUENCE = p_USER_SEQUENCE
	  and jwot.INTERFACE_TYPE = p_intf_type
	  and jwot.status is null;

  l_header := 'RSC';
  l_action_flag := 'D';

  x_return_status := FND_API.G_RET_STS_ERROR;
  fnd_message.clear;
  fnd_message.set_name ('JTF', 'JTY_OTH_TERR_INVALID_ID');
  X_Msg_Data := fnd_message.get();
  debugmsg('VALIDATE_TERRITORY_RECORDS: Validate JTY_OTH_TERR_INVALID_ID  : ' );
 	update JTY_WEBADI_OTH_TERR_INTF jwot
	set status = x_return_status,
	error_msg = X_Msg_Data
	where ( (jwot.TERR_ID IS NULL and jwot.header = 'TERR')
	   OR   (jwot.header = 'QUAL' and jwot.TERR_QUAL_ID1 IS NULL
			 and jwot.TERR_QUAL_ID2 IS NULL and jwot.TERR_QUAL_ID3 IS NULL
			 and jwot.TERR_QUAL_ID4 IS NULL and jwot.TERR_QUAL_ID5 IS NULL
			 and jwot.TERR_QUAL_ID6 IS NULL and jwot.TERR_QUAL_ID7 IS NULL
			 and jwot.TERR_QUAL_ID8 IS NULL and jwot.TERR_QUAL_ID9 IS NULL
			 and jwot.TERR_QUAL_ID10 IS NULL and jwot.TERR_QUAL_ID11 IS NULL
			 and jwot.TERR_QUAL_ID12 IS NULL and jwot.TERR_QUAL_ID13 IS NULL
			 and jwot.TERR_QUAL_ID14 IS NULL and jwot.TERR_QUAL_ID15 IS NULL
			 and jwot.TERR_QUAL_ID16 IS NULL and jwot.TERR_QUAL_ID17 IS NULL
			 and jwot.TERR_QUAL_ID18 IS NULL and jwot.TERR_QUAL_ID19 IS NULL
			 and jwot.TERR_QUAL_ID20 IS NULL and jwot.TERR_QUAL_ID21 IS NULL
			 and jwot.TERR_QUAL_ID22 IS NULL and jwot.TERR_QUAL_ID23 IS NULL
			 and jwot.TERR_QUAL_ID24 IS NULL and jwot.TERR_QUAL_ID25 IS NULL
			 and jwot.TERR_QUAL_ID26 IS NULL and jwot.TERR_QUAL_ID27 IS NULL
			 and jwot.TERR_QUAL_ID28 IS NULL and jwot.TERR_QUAL_ID29 IS NULL
			 and jwot.TERR_QUAL_ID30 IS NULL and jwot.TERR_QUAL_ID31 IS NULL
			 and jwot.TERR_QUAL_ID32 IS NULL and jwot.TERR_QUAL_ID33 IS NULL
			 and jwot.TERR_QUAL_ID34 IS NULL and jwot.TERR_QUAL_ID35 IS NULL
			 and jwot.TERR_QUAL_ID36 IS NULL and jwot.TERR_QUAL_ID37 IS NULL
			 and jwot.TERR_QUAL_ID38 IS NULL and jwot.TERR_QUAL_ID39 IS NULL
			 and jwot.TERR_QUAL_ID40 IS NULL and jwot.TERR_QUAL_ID41 IS NULL
			 and jwot.TERR_QUAL_ID42 IS NULL and jwot.TERR_QUAL_ID43 IS NULL
			 and jwot.TERR_QUAL_ID44 IS NULL and jwot.TERR_QUAL_ID45 IS NULL
			 and jwot.TERR_QUAL_ID46 IS NULL and jwot.TERR_QUAL_ID47 IS NULL
			 and jwot.TERR_QUAL_ID48 IS NULL and jwot.TERR_QUAL_ID49 IS NULL
			 and jwot.TERR_QUAL_ID50 IS NULL and jwot.TERR_QUAL_ID51 IS NULL
			 and jwot.TERR_QUAL_ID52 IS NULL and jwot.TERR_QUAL_ID53 IS NULL
			 and jwot.TERR_QUAL_ID54 IS NULL and jwot.TERR_QUAL_ID55 IS NULL
			 and jwot.TERR_QUAL_ID56 IS NULL and jwot.TERR_QUAL_ID57 IS NULL
			 and jwot.TERR_QUAL_ID58 IS NULL and jwot.TERR_QUAL_ID59 IS NULL
			 and jwot.TERR_QUAL_ID60 IS NULL and jwot.TERR_QUAL_ID61 IS NULL
			 and jwot.TERR_QUAL_ID62 IS NULL and jwot.TERR_QUAL_ID63 IS NULL
			 and jwot.TERR_QUAL_ID64 IS NULL and jwot.TERR_QUAL_ID65 IS NULL
			 and jwot.TERR_QUAL_ID66 IS NULL and jwot.TERR_QUAL_ID67 IS NULL
			 and jwot.TERR_QUAL_ID68 IS NULL and jwot.TERR_QUAL_ID69 IS NULL
			 and jwot.TERR_QUAL_ID70 IS NULL and jwot.TERR_QUAL_ID71 IS NULL
			 and jwot.TERR_QUAL_ID72 IS NULL and jwot.TERR_QUAL_ID73 IS NULL
			 and jwot.TERR_QUAL_ID74 IS NULL and jwot.TERR_QUAL_ID75 IS NULL
			 )
	   OR EXISTS (select 1 from jty_webadi_resources jwr
	   	  		  where jwot.lay_seq_num = jwr.lay_seq_num
				    and jwr.terr_rsc_id is null
					and jwr.header = l_header)
		  )
	  and jwot.USER_SEQUENCE = p_USER_SEQUENCE
	  and jwot.INTERFACE_TYPE = p_intf_type
	  and jwot.action_flag = l_action_flag
	  and jwot.status is null;

  l_action_flag := 'U';

  x_return_status := FND_API.G_RET_STS_ERROR;
  fnd_message.clear;
  fnd_message.set_name ('JTF', 'JTY_OTH_TERR_INVALID_TEMPLATE');
  X_Msg_Data := fnd_message.get();
  debugmsg('VALIDATE_TERRITORY_RECORDS: Validate JTY_OTH_TERR_INVALID_TEMPLATE  : ' );
  	update JTY_WEBADI_OTH_TERR_INTF jwot
	set jwot.status = x_return_status,
	jwot.error_msg = X_Msg_Data
	where not exists ( SELECT 1
				   FROM jtf_terr_all jt
				   WHERE jt.TERRITORY_TYPE_ID = jwot.TERR_TYPE_ID
					 and jt.terr_id = jwot.TERR_ID
		  			 AND jt.ORG_ID = jwot.ORG_ID )
	  and jwot.user_sequence = p_user_sequence
	  and jwot.interface_type = p_intf_type
	  and jwot.action_flag = l_action_flag
	  and jwot.header <> l_header
	  and jwot.status is null
	  AND jwot.TERR_ID is not null;


  x_return_status := FND_API.G_RET_STS_ERROR;
  fnd_message.clear;
  fnd_message.set_name ('JTF', 'JTY_OTH_TERR_NO_TEMPLATE');
  X_Msg_Data := fnd_message.get();
  debugmsg('VALIDATE_TERRITORY_RECORDS: Validate JTY_OTH_TERR_NO_TEMPLATE  : ' );
 	update JTY_WEBADI_OTH_TERR_INTF jwot
	set status = x_return_status,
	error_msg = X_Msg_Data
	where jwot.TERR_TYPE_ID is null
	  AND jwot.user_sequence = p_user_sequence
	  and jwot.interface_type = p_intf_type
	  and jwot.header <> l_header
	  and jwot.status is null;

-- Commented it as a part of fix for bug #5479649
 /*
  x_return_status := FND_API.G_RET_STS_ERROR;
  fnd_message.clear;
  fnd_message.set_name ('JTF', 'JTY_OTH_TERR_INVALID_ACCESS');
  X_Msg_Data := fnd_message.get();
  debugmsg('VALIDATE_TERRITORY_RECORDS: Validate JTY_OTH_TERR_INVALID_ACCESS  : ' );
   	update JTY_WEBADI_OTH_TERR_INTF jwot
   	set jwot.status = x_return_status,
	jwot.error_msg = X_Msg_Data
	where exists
	  (select 1 from JTY_WEBADI_RESOURCES jwr
    	  where jwot.lay_seq_num = jwr.lay_seq_num
    	  AND jwr.TRANS_ACCESS_CODE1 is null
    	  AND jwr.TRANS_ACCESS_CODE2 is null
    	  AND jwr.TRANS_ACCESS_CODE3 is null
    	  AND jwr.TRANS_ACCESS_CODE4 is null
    	  AND jwr.TRANS_ACCESS_CODE5 is null
    	  AND jwr.TRANS_ACCESS_CODE6 is null
    	  AND jwr.TRANS_ACCESS_CODE7 is null
    	  AND jwr.TRANS_ACCESS_CODE8 is null
    	  AND jwr.TRANS_ACCESS_CODE9 is null
    	  AND jwr.TRANS_ACCESS_CODE10 is null
    	  and jwr.USER_SEQUENCE = jwot.USER_SEQUENCE
    	  and jwr.interface_type = jwot.interface_type
		  and jwr.header = jwot.header)
	  and jwot.user_sequence = p_user_sequence
	  and jwot.interface_type = p_intf_type
	  and jwot.header = l_header
	  and jwot.status is null;
  */

-- Fix for bug #5583243 START
 -- if any access is left blank while uploading the data from excel,
 -- then the upload should populate the value 'NONE' in the database.
  debugmsg('VALIDATE_TERRITORY_RECORDS: Validate Update None if access is left blank : ' );
  UPDATE  JTY_WEBADI_RESOURCES jut
     SET    jut.TRANS_ACCESS_CODE1  = NVL(jut.TRANS_ACCESS_CODE1,'NONE')
          , jut.TRANS_ACCESS_CODE2  = NVL(jut.TRANS_ACCESS_CODE2,'NONE')
          , jut.TRANS_ACCESS_CODE3  = NVL(jut.TRANS_ACCESS_CODE3,'NONE')
          , jut.TRANS_ACCESS_CODE4  = NVL(jut.TRANS_ACCESS_CODE4,'NONE')
          , jut.TRANS_ACCESS_CODE5  = NVL(jut.TRANS_ACCESS_CODE5,'NONE')
          , jut.TRANS_ACCESS_CODE6  = NVL(jut.TRANS_ACCESS_CODE6,'NONE')
          , jut.TRANS_ACCESS_CODE7  = NVL(jut.TRANS_ACCESS_CODE7,'NONE')
          , jut.TRANS_ACCESS_CODE8  = NVL(jut.TRANS_ACCESS_CODE8,'NONE')
          , jut.TRANS_ACCESS_CODE9  = NVL(jut.TRANS_ACCESS_CODE9,'NONE')
          , jut.TRANS_ACCESS_CODE10 = NVL(jut.TRANS_ACCESS_CODE10,'NONE')
  WHERE jut.USER_SEQUENCE = p_user_sequence
    AND jut.header = 'RSC'
    AND jut.INTERFACE_TYPE = p_intf_type;

-- Fix for bug #5583243 END

-- Fix for bug #5479649  START
-- An error message should be displayed when all the access types
-- are NONE for all the transaction type of a resource.
  x_return_status := FND_API.G_RET_STS_ERROR;
  fnd_message.clear;
  fnd_message.set_name ('JTF', 'JTY_OTH_TERR_INVALID_ACCESS');
  X_Msg_Data := fnd_message.get();
  debugmsg('VALIDATE_TERRITORY_RECORDS: Validate JTY_OTH_TERR_INVALID_ACCESS  : ' );
  	update JTY_WEBADI_OTH_TERR_INTF jwot
   	set jwot.status = x_return_status,
	jwot.error_msg = X_Msg_Data
	where exists
	  (select 1 from JTY_WEBADI_RESOURCES jwr
    	  where jwot.lay_seq_num = jwr.lay_seq_num
    	  AND jwr.TRANS_ACCESS_CODE1  = 'NONE'
    	  AND jwr.TRANS_ACCESS_CODE2  = 'NONE'
    	  AND jwr.TRANS_ACCESS_CODE3  = 'NONE'
    	  AND jwr.TRANS_ACCESS_CODE4  = 'NONE'
    	  AND jwr.TRANS_ACCESS_CODE5  = 'NONE'
    	  AND jwr.TRANS_ACCESS_CODE6  = 'NONE'
    	  AND jwr.TRANS_ACCESS_CODE7  = 'NONE'
    	  AND jwr.TRANS_ACCESS_CODE8  = 'NONE'
    	  AND jwr.TRANS_ACCESS_CODE9  = 'NONE'
    	  AND jwr.TRANS_ACCESS_CODE10 = 'NONE'
    	  and jwr.USER_SEQUENCE = jwot.USER_SEQUENCE
    	  and jwr.interface_type = jwot.interface_type
		  and jwr.header = jwot.header)
	  and jwot.user_sequence = p_user_sequence
	  and jwot.interface_type = p_intf_type
	  and jwot.header = l_header
	  and jwot.status is null;

-- Fix for bug #5479649  END.

-- Fix for bug # 6372728 START
 -- Should display a error message when user tries to add a duplicate reosurce.
  x_return_status := FND_API.G_RET_STS_ERROR;
  fnd_message.clear;
  fnd_message.set_name ('JTF', 'JTF_TTY_DUPLICATE_RESOURCE');
  X_Msg_Data := fnd_message.get();
   debugmsg('VALIDATE_TERRITORY_RECORDS: Validate JTF_TTY_DUPLICATE_RESOURCE  : ' );
   update JTY_WEBADI_OTH_TERR_INTF jwot
    set  status = x_return_status
       , error_msg = X_Msg_Data
   where jwot.USER_SEQUENCE = p_USER_SEQUENCE
     and jwot.INTERFACE_TYPE = p_intf_type
     and jwot.status is null
     and jwot.action_flag = 'C'
     and jwot.header = 'RSC'
     and exists( select 1
                 from JTF_TERR_RSC_ALL jtr,JTY_WEBADI_RESOURCES jwr
                 where jwr.USER_SEQUENCE = jwot.USER_SEQUENCE
                    and jwr.header = jwot.header
                    and jwr.INTERFACE_TYPE = jwot.INTERFACE_TYPE
                    and jwot.lay_seq_num = jwr.lay_seq_num
                    and jtr.TERR_ID = jwr.TERR_ID
                    and jtr.RESOURCE_ID = jwr.RESOURCE_ID
                    and nvl(jtr.role, 'X') = nvl(jwr.role_code, 'X')
                    and nvl(jtr.group_id, -1) = nvl(jwr.group_id, -1)
                    and decode(jtr.resource_type,'RS_GROUP',1,'RS_TEAM',2,'RS_ROLE',3,0) = jwr.resource_type
                    and ( jwr.res_start_date between jtr.start_date_active and  jtr.end_date_active
                    or jwr.res_end_date between jtr.start_date_active and  jtr.end_date_active )
                );
-- Fix for bug # 6372728 END

	-- Fix for bug # 9124144  START
     update JTY_WEBADI_OTH_TERR_INTF jwot
        set  status = x_return_status
           , error_msg = X_Msg_Data
       where jwot.USER_SEQUENCE = p_USER_SEQUENCE
         and jwot.INTERFACE_TYPE = p_intf_type
         and jwot.status is null
         and jwot.action_flag = 'C'
         and jwot.header = 'RSC'
         and exists( select 1
                     from JTY_WEBADI_RESOURCES jwr1,JTY_WEBADI_RESOURCES jwr2
                     where jwr1.USER_SEQUENCE = jwot.USER_SEQUENCE
                        and jwr1.header = jwot.header
                        and jwr1.INTERFACE_TYPE = jwot.INTERFACE_TYPE
                        and jwot.lay_seq_num = jwr1.lay_seq_num
                        and jwr1.lay_seq_num <> jwr2.lay_seq_num
                        and jwr1.TERR_ID = jwr2.TERR_ID
                        and jwr1.RESOURCE_ID = jwr2.RESOURCE_ID
                        and nvl(jwr1.role_code, 'X') = nvl(jwr2.role_code, 'X')
                        and nvl(jwr1.group_id, -1) = nvl(jwr2.group_id, -1)
                        and jwr1.resource_type = jwr2.resource_type
                        and ( jwr2.res_start_date between jwr1.res_start_date and  jwr1.res_end_date
                        or jwr2.res_end_date between jwr1.res_start_date and  jwr1.res_end_date )
                    );
	-- Fix for bug # 9124144  END

  x_return_status := FND_API.G_RET_STS_ERROR;
  fnd_message.clear;
  fnd_message.set_name ('JTF', 'JTY_OTH_TERR_RSC_START_DATE');
  X_Msg_Data := fnd_message.get();
  debugmsg('VALIDATE_TERRITORY_RECORDS: Validate JTY_OTH_TERR_RSC_START_DATE  : ' );
   	UPDATE JTY_WEBADI_OTH_TERR_INTF jwot
   	set jwot.status = x_return_status,
	jwot.error_msg = X_Msg_Data
	where exists
	  (select 1 from JTY_WEBADI_RESOURCES jwr
    	  where jwot.lay_seq_num = jwr.lay_seq_num
    	  and jwr.USER_SEQUENCE = jwot.USER_SEQUENCE
    	  and jwr.interface_type = jwot.interface_type
		  and jwr.header = jwot.header
		  and NOT(jwr.RES_START_DATE between jwot.TERR_START_DATE and jwot.TERR_END_DATE)
		  --and (jwr.RES_START_DATE <= nvl(jwot.TERR_START_DATE,sysdate))
		  )
	  and jwot.user_sequence = p_user_sequence
	  and jwot.interface_type = p_intf_type
	  and jwot.header = l_header
	  and jwot.status is null;

  x_return_status := FND_API.G_RET_STS_ERROR;
  fnd_message.clear;
  fnd_message.set_name ('JTF', 'JTY_OTH_TERR_RSC_END_DATE');
  X_Msg_Data := fnd_message.get();
  debugmsg('VALIDATE_TERRITORY_RECORDS: Validate JTY_OTH_TERR_RSC_END_DATE  : ' );
   	UPDATE JTY_WEBADI_OTH_TERR_INTF jwot
   	set jwot.status = x_return_status,
	jwot.error_msg = X_Msg_Data
	where exists
	  (select 1 from JTY_WEBADI_RESOURCES jwr
    	  where jwot.lay_seq_num = jwr.lay_seq_num
    	  and jwr.USER_SEQUENCE = jwot.USER_SEQUENCE
    	  and jwr.interface_type = jwot.interface_type
		  and jwr.header = jwot.header
		  and not (jwr.RES_END_DATE between nvl(jwot.TERR_START_DATE,sysdate)
		  	  and NVL(jwot.TERR_END_DATE, ADD_MONTHS(NVL(jwot.TERR_START_DATE,SYSDATE), 12)))
		  )
	  and jwot.user_sequence = p_user_sequence
	  and jwot.interface_type = p_intf_type
	  and jwot.header = l_header
	  and jwot.status is null;


  l_header := 'QUAL';
  x_return_status := FND_API.G_RET_STS_ERROR;
  fnd_message.clear;
  fnd_message.set_name ('JTF', 'JTY_OTH_TERR_INVALID_QUAL');
  X_Msg_Data := fnd_message.get();
  debugmsg('VALIDATE_TERRITORY_RECORDS: Validate JTY_OTH_TERR_INVALID_QUAL  : ' );
  open get_qual_csr(p_user_sequence, p_intf_type, l_header);
  fetch get_qual_csr bulk collect into qual_rec.qualifier_name, qual_rec.lay_seq_num;
  close get_qual_csr;
  debugmsg('VALIDATE_TERRITORY_RECORDS: Validate qual_rec.lay_seq_num.count  : ' || qual_rec.lay_seq_num.count );
  if qual_rec.lay_seq_num.count > 0 then
    forall i in qual_rec.lay_seq_num.first..qual_rec.lay_seq_num.last
	  update JTY_WEBADI_OTH_TERR_INTF jwot
	  set jwot.status = x_return_status,
	  	  jwot.error_msg = decode(jwot.error_msg,null,X_Msg_Data||': '||qual_rec.qualifier_name(i),
		  				   	 jwot.error_msg ||', ' || qual_rec.qualifier_name(i))
	  where jwot.lay_seq_num = qual_rec.lay_seq_num(i)
	    and jwot.user_sequence = p_user_sequence
	  	and jwot.interface_type = p_intf_type
	  	and jwot.header = l_header;
  end if;

  l_header := 'TERR';

  x_return_status := FND_API.G_RET_STS_ERROR;
  fnd_message.clear;
  fnd_message.set_name ('JTF', 'JTY_OTH_TERR_START_DATE');
  X_Msg_Data := fnd_message.get();
  debugmsg('VALIDATE_TERRITORY_RECORDS: Validate JTY_OTH_TERR_START_DATE  : ' );
    UPDATE JTY_WEBADI_OTH_TERR_INTF jwot
	set status = x_return_status,
	error_msg = X_Msg_Data
    where jwot.interface_type = p_intf_type
      AND jwot.HEADER= l_header
	  and jwot.USER_SEQUENCE = p_USER_SEQUENCE
      AND jwot.hierarchy is not null
	  and jwot.TERR_START_DATE is not null
	  and jwot.status is null
      and ( exists ( select 1
    		     from JTY_WEBADI_OTH_TERR_INTF jwot2
    			 where jwot.parent_terr_id is null
    			   and NOT(jwot.TERR_START_DATE between NVL(jwot2.terr_start_date,SYSDATE)
				   and NVL(jwot2.TERR_END_DATE, ADD_MONTHS(NVL(jwot2.TERR_START_DATE,SYSDATE), 12)))
    			   and jwot.parent_terr_name = jwot2.terr_name)
     	or exists ( select 1
    		     from JTF_TERR_ALL jta
    			 where jwot.parent_terr_id = jta.terr_id
    			   and NOT(jwot.TERR_START_DATE between jta.START_DATE_ACTIVE and jta.END_DATE_ACTIVE))
     );

  x_return_status := FND_API.G_RET_STS_ERROR;
  fnd_message.clear;
  fnd_message.set_name ('JTF', 'JTY_OTH_TERR_END_DATE');
  X_Msg_Data := fnd_message.get();
  debugmsg('VALIDATE_TERRITORY_RECORDS: Validate JTY_OTH_TERR_END_DATE  : ' );
    UPDATE JTY_WEBADI_OTH_TERR_INTF jwot
	set status = x_return_status,
	error_msg = X_Msg_Data
    where jwot.interface_type = p_intf_type
      AND jwot.HEADER= l_header
	  and jwot.USER_SEQUENCE = p_USER_SEQUENCE
      AND jwot.hierarchy is not null
	  AND jwot.TERR_END_DATE is not null
	  and jwot.status is null
      and (exists ( select 1
    		     from JTY_WEBADI_OTH_TERR_INTF jwot2
    			 where jwot.parent_terr_id is null
    			   and NOT (jwot.TERR_END_DATE between NVL(jwot2.terr_start_date,SYSDATE)
				   and NVL(jwot2.TERR_END_DATE, ADD_MONTHS(NVL(jwot2.TERR_START_DATE,SYSDATE), 12)))
    			   and jwot.parent_terr_name = jwot2.terr_name)
     	or exists ( select 1
    		     from JTF_TERR_ALL jta
    			 where jwot.parent_terr_id = jta.terr_id
    			   and NOT(jwot.TERR_END_DATE between jta.START_DATE_ACTIVE and jta.END_DATE_ACTIVE))
     );

-- Fix for bug #7707288 START

 -- Should display a error message when user tries to create a territory
 -- with same name.
  x_return_status := FND_API.G_RET_STS_ERROR;
  fnd_message.clear;
  fnd_message.set_name ('JTF', 'JTY_TTY_DUPLICATE_TERR');
  X_Msg_Data := fnd_message.get();
  debugmsg('VALIDATE_TERRITORY_RECORDS: Validate JTY_TTY_DUPLICATE_TERR  : ' );

   update JTY_WEBADI_OTH_TERR_INTF jwot
    set  status = x_return_status
       , error_msg = X_Msg_Data
   where jwot.header = 'TERR'
     and jwot.action_flag='C'
     and jwot.USER_SEQUENCE = p_USER_SEQUENCE
     and jwot.status is null
     and exists( select 1
                 from JTF_TERR_ALL jta
                 where jta.name = jwot.terr_name
                    and ( to_date(jwot.terr_start_date)
                            BETWEEN to_date(jta.start_date_active) AND to_date(jta.end_date_Active)
                         or  to_date(jwot.terr_end_date) BETWEEN to_date(jta.start_date_active) AND to_date(jta.end_date_Active)
                        )
                );

   -- The above fix checks for duplicate territory name only while creating a new territory.
   -- The following fix checks for the duplicate territory name while updating a territory. Fix for bug: 8289489.
   update JTY_WEBADI_OTH_TERR_INTF jwot
    set  status = x_return_status
       , error_msg = X_Msg_Data
   where jwot.header = 'TERR'
     and jwot.action_flag='U'
     and jwot.USER_SEQUENCE = p_USER_SEQUENCE
     and jwot.status is null
     and exists( select 1
                 from JTF_TERR_ALL jta
                 where jta.name = jwot.terr_name
                    and jta.terr_id <> jwot.terr_id
                    and ( to_date(jwot.terr_start_date)
                            BETWEEN to_date(jta.start_date_active) AND to_date(jta.end_date_Active)
                          or  to_date(jwot.terr_end_date) BETWEEN to_date(jta.start_date_active) AND to_date(jta.end_date_Active)
                        )
                );

-- Fix for bug # 7707288 END

-- Fix for bug #8208298 START

 -- Should display a error message when user tries to create a territory
 -- with empty Territory DFF.
  x_return_status := FND_API.G_RET_STS_ERROR;
  fnd_message.clear;
  fnd_message.set_name ('JTF', 'JTY_TERR_OTH_MTERR_DFF_NA');
  X_Msg_Data := fnd_message.get();
  debugmsg('VALIDATE_TERRITORY_RECORDS: Validate JTY_TERR_OTH_MTERR_DFF_NA  : ' );
    update JTY_WEBADI_OTH_TERR_INTF jwot
      set  status = x_return_status
         , error_msg = X_Msg_Data
     where jwot.header = 'TERR'
       and jwot.action_flag IN ('C', 'U')
       and jwot.USER_SEQUENCE = p_USER_SEQUENCE
       and jwot.status is null
       and attribute_category is NULL
       ;

-- Fix for bug # 8208298 END


  x_return_status := FND_API.G_RET_STS_ERROR;
  fnd_message.clear;
  fnd_message.set_name ('JTF', 'JTY_OTH_TERR_NO_ACCESS');
  X_Msg_Data := fnd_message.get();
  debugmsg('VALIDATE_TERRITORY_RECORDS: Validate JTY_OTH_TERR_NO_ACCESS  : ' );
 	update JTY_WEBADI_OTH_TERR_INTF jwot
	set status = x_return_status,
	error_msg = X_Msg_Data
	where (jwot.org_id is null
	   or  mo_global.check_access(jwot.org_id) <> 'Y')
	  and jwot.USER_SEQUENCE = p_USER_SEQUENCE
	  and jwot.INTERFACE_TYPE = p_intf_type
	  and jwot.status is null;

  UPDATE JTY_WEBADI_OTH_TERR_INTF jwot
  set (status,error_msg) = (SELECT jwot2.STATUS, jwot2.error_msg
  	  		    FROM JTY_WEBADI_OTH_TERR_INTF jwot2
				where jwot.terr_name = jwot2.terr_name
				  and jwot2.header = l_header
				  and jwot.USER_SEQUENCE = jwot2.USER_SEQUENCE
				  and jwot.INTERFACE_TYPE = jwot2.INTERFACE_TYPE)
  WHERE jwot.USER_SEQUENCE = p_USER_SEQUENCE
	and jwot.INTERFACE_TYPE = p_intf_type
	and jwot.header <> l_header
	and jwot.status is null;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  debugmsg('VALIDATE_TERRITORY_RECORDS: Validate x_return_status  : '  || x_return_status);
  select count(*) into l_count
  from JTY_WEBADI_OTH_TERR_INTF jwot
  where status is not null
    and jwot.USER_SEQUENCE = p_USER_SEQUENCE
	and jwot.INTERFACE_TYPE = p_intf_type;

  --dbms_output.put_line ('l_count: '||l_count);
  debugmsg('VALIDATE_TERRITORY_RECORDS: Validate l_count  : '  || l_count);
  if l_count > 0 then
    UPDATE  JTY_WEBADI_OTH_TERR_INTF jwot
	set status = x_return_status
	where status is null
    and jwot.USER_SEQUENCE = p_USER_SEQUENCE
	and jwot.INTERFACE_TYPE = p_intf_type;

	x_return_status := FND_API.G_RET_STS_ERROR;
  else
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  end if;
  debugmsg('VALIDATE_TERRITORY_RECORDS: Validate end x_return_status  : '  || x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
     debugmsg('VALIDATE_TERRITORY_RECORDS: Validate EXCEPTION others  : '  || SQLERRM(SQLCODE()));
	  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
END VALIDATE_TERRITORY_RECORDS;

PROCEDURE SET_CREATE_RECORDS(
  p_user_sequence 			 IN  NUMBER,
  p_intf_type				 IN	 VARCHAR2)
IS
  l_action_flag varchar2(1) := 'C';
  l_intf_type	varchar2(1);
  l_login_id number;
BEGIN

  l_login_id := fnd_global.login_id;
   l_intf_type := p_intf_type;

   update JTY_WEBADI_OTH_TERR_INTF jwot
   set LAST_UPDATE_LOGIN = l_login_id,
   (terr_start_date,TERR_END_DATE) =
       (SELECT NVL(jwot2.TERR_START_DATE,TRUNC(SYSDATE)),
   	    NVL(jwot2.TERR_END_DATE, ADD_MONTHS(NVL(jwot2.TERR_START_DATE,TRUNC(SYSDATE)), 12) )
		FROM JTY_WEBADI_OTH_TERR_INTF jwot2
		WHERE jwot.terr_id = jwot2.terr_id
		  and jwot.user_sequence = jwot2.user_sequence
		  and jwot2.header = 'TERR'
		  and rownum = 1),
   usage_id = (select jwot2.usage_id from
   	   			JTY_WEBADI_OTH_TERR_INTF jwot2
				where jwot.user_sequence = jwot2.user_sequence
				and interface_type = 'D'
				and jwot2.usage_id is not null
				and rownum = 1)
	where jwot.user_sequence = p_user_sequence
	  and jwot.interface_type = l_intf_type
	  and jwot.action_flag = l_action_flag
	  and jwot.status is null;

    UPDATE JTY_WEBADI_OTH_TERR_INTF jwot
    SET (TERR_ID, TERR_START_DATE, TERR_END_DATE) =
				  (select jta.terr_id, NVL(jwot.TERR_START_DATE,jta.START_DATE_ACTIVE)
				  , NVL(jwot.TERR_END_DATE,jta.END_DATE_ACTIVE)
				   from jtf_terr_all jta
				   where jta.terr_id = jwot.terr_id
				     --and jta.parent_territory_id = jwot.parent_terr_id
				     and rownum = 1)
    where status is null
  	  and interface_type = l_intf_type
  	  and user_sequence = p_user_sequence
	  and exists (select 1
				   from jtf_terr_all jta
				   where jta.terr_id = jwot.terr_id
				     --and jta.parent_territory_id = jwot.parent_terr_id
					 ) ;

	--dbms_output.put_line(' # records processed for intf table:  '||SQL%ROWCOUNT);
	update 	JTY_WEBADI_OTH_TERR_INTF
	set QUAL1_VALUE_ID = NULL, QUAL2_VALUE_ID = NULL
	, QUAL3_VALUE_ID = NULL, QUAL4_VALUE_ID = NULL
	, QUAL5_VALUE_ID = NULL, QUAL6_VALUE_ID = NULL
	, QUAL7_VALUE_ID = NULL, QUAL8_VALUE_ID = NULL
	, QUAL9_VALUE_ID = NULL, QUAL10_VALUE_ID = NULL
	, QUAL11_VALUE_ID = NULL, QUAL12_VALUE_ID = NULL
	, QUAL13_VALUE_ID = NULL, QUAL14_VALUE_ID = NULL
	, QUAL15_VALUE_ID = NULL, QUAL16_VALUE_ID = NULL
	, QUAL17_VALUE_ID = NULL, QUAL18_VALUE_ID = NULL
	, QUAL19_VALUE_ID = NULL, QUAL20_VALUE_ID = NULL
	, QUAL21_VALUE_ID = NULL, QUAL22_VALUE_ID = NULL
	, QUAL23_VALUE_ID = NULL, QUAL24_VALUE_ID = NULL
	, QUAL25_VALUE_ID = NULL, QUAL26_VALUE_ID = NULL
	, QUAL27_VALUE_ID = NULL, QUAL28_VALUE_ID = NULL
	, QUAL29_VALUE_ID = NULL, QUAL30_VALUE_ID = NULL
	, QUAL31_VALUE_ID = NULL, QUAL32_VALUE_ID = NULL
	, QUAL33_VALUE_ID = NULL, QUAL34_VALUE_ID = NULL
	, QUAL35_VALUE_ID = NULL, QUAL36_VALUE_ID = NULL
	, QUAL37_VALUE_ID = NULL, QUAL38_VALUE_ID = NULL
	, QUAL39_VALUE_ID = NULL, QUAL40_VALUE_ID = NULL
	, QUAL41_VALUE_ID = NULL, QUAL42_VALUE_ID = NULL
	, QUAL43_VALUE_ID = NULL, QUAL44_VALUE_ID = NULL
	, QUAL45_VALUE_ID = NULL, QUAL46_VALUE_ID = NULL
	, QUAL47_VALUE_ID = NULL, QUAL48_VALUE_ID = NULL
	, QUAL49_VALUE_ID = NULL, QUAL50_VALUE_ID = NULL
	, QUAL51_VALUE_ID = NULL, QUAL52_VALUE_ID = NULL
	, QUAL53_VALUE_ID = NULL, QUAL54_VALUE_ID = NULL
	, QUAL55_VALUE_ID = NULL, QUAL56_VALUE_ID = NULL
	, QUAL57_VALUE_ID = NULL, QUAL58_VALUE_ID = NULL
	, QUAL59_VALUE_ID = NULL, QUAL60_VALUE_ID = NULL
	, QUAL61_VALUE_ID = NULL, QUAL62_VALUE_ID = NULL
	, QUAL63_VALUE_ID = NULL, QUAL64_VALUE_ID = NULL
	, QUAL65_VALUE_ID = NULL, QUAL66_VALUE_ID = NULL
	, QUAL67_VALUE_ID = NULL, QUAL68_VALUE_ID = NULL
	, QUAL69_VALUE_ID = NULL, QUAL70_VALUE_ID = NULL
	, QUAL71_VALUE_ID = NULL, QUAL72_VALUE_ID = NULL
	, QUAL73_VALUE_ID = NULL, QUAL74_VALUE_ID = NULL
	, QUAL75_VALUE_ID = NULL
    where status is null
  	  and interface_type = l_intf_type
  	  and user_sequence = p_user_sequence
	  and action_flag = l_action_flag
	  and header = 'QUAL';

	UPDATE JTY_WEBADI_OTH_TERR_INTF jwot
	set jwot.terr_id = null
	where jwot.status is null
  	  and jwot.interface_type = l_intf_type
  	  and jwot.user_sequence = p_user_sequence
	  and jwot.action_flag = l_action_flag
	  and exists (select 1 from JTY_WEBADI_OTH_TERR_INTF jwot2
	  	  		  where jwot.terr_id = jwot2.terr_id
				    and jwot.action_flag = jwot2.action_flag
					and jwot.user_sequence = jwot2.user_sequence
					and jwot.interface_type = jwot2.interface_type
					and jwot2.header = 'TERR');

    UPDATE JTY_WEBADI_RESOURCES jwr
    SET TERR_ID = (select jwot.terr_id
				   from JTY_WEBADI_OTH_TERR_INTF jwot
				   where jwr.lay_seq_num = jwot.lay_seq_num
				     and rownum = 1) ,
	TERR_RSC_ID = NULL,
	TERR_RSC_ACCESS_ID1 = NULL, TERR_RSC_ACCESS_ID2 = NULL,
	TERR_RSC_ACCESS_ID3 = NULL, TERR_RSC_ACCESS_ID4 = NULL,
	TERR_RSC_ACCESS_ID5 = NULL, TERR_RSC_ACCESS_ID6 = NULL,
	TERR_RSC_ACCESS_ID7 = NULL, TERR_RSC_ACCESS_ID8 = NULL,
	TERR_RSC_ACCESS_ID9 = NULL, TERR_RSC_ACCESS_ID10 = NULL
    where exists
	  ( select 1 from JTY_WEBADI_OTH_TERR_INTF jwot
	  	where jwot.interface_type = l_intf_type
  		  and jwot.user_sequence = p_user_sequence
		  and jwot.status is null
		  and jwot.action_flag = l_action_flag
		  and jwot.lay_seq_num = jwr.lay_seq_num
		  and jwot.header = 'RSC');

END SET_CREATE_RECORDS;

PROCEDURE UPDATE_TERR_QUAL_ID(
    P_USER_SEQUENCE			  IN  NUMBER,
	P_INTF_TYPE				  IN  VARCHAR2,
	P_HEADER				  IN  VARCHAR2)

IS

  cursor get_terr_qual_id_csr(
  v_header			varchar2,
  v_user_sequence	number,
  v_intf_type		varchar2,
  v_qual_num 		number
  ) IS
  select jtq.terr_qual_id, jwot.lay_seq_num
  from JTY_WEBADI_QUAL_HEADER qgt , jtf_terr_qual_all jtq, JTY_WEBADI_OTH_TERR_INTF jwot
  WHERE qgt.qual_usg_id = jtq.qual_usg_id
  	and jtq.org_id = jwot.org_id
  	AND qgt.user_sequence = jwot.user_sequence
  	AND jtq.terr_id = jwot.terr_id
  	and jwot.header = v_header
    AND jwot.USER_SEQUENCE = v_user_sequence
    AND jwot.interface_type = v_intf_type
	and qgt.qualifier_num = v_qual_num
	and jwot.status is null
  group by jwot.terr_id, jtq.terr_qual_id, jwot.lay_seq_num;

    TYPE Terr_Qual_Rec_Type  IS RECORD
    (  TERR_QUAL_ID                  number_tbl_type,
	   lay_seq_num				 	 number_tbl_type);

	l_terr_qual_rec Terr_Qual_Rec_Type;

BEGIN

  for i in 1..75 loop
    open get_terr_qual_id_csr(p_header, p_user_sequence, p_intf_type, i);
    fetch get_terr_qual_id_csr bulk collect into l_terr_qual_rec.terr_qual_id,
      --l_terr_qual_rec.qualifier_num,
	  l_terr_qual_rec.lay_seq_num;
    close get_terr_qual_id_csr;

    if l_terr_qual_rec.lay_seq_num.count > 0 then
	  --dbms_output.put_line ('i: '||i);
      case i
	    when 1 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id1 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('1 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 2 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id2 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('2 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 3 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id3 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('3 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 4 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id4 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('4 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 5 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id5 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('5 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 6 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id6 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('6 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 7 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id7 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('7 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 8 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id8 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('8 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 9 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id9 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('9 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 10 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id10 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('10 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 11 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id11 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('11 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 12 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id12 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('12 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 13 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id13 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('13 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 14 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id14 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('14 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 15 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id15 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('15 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 16 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id16 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('16 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 17 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id17 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('17 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 18 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id18 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('18 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 19 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id19 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('19 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 20 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id20 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('20 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 21 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id21 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('21 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 22 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id22 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('22 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 23 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id23 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('23 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 24 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id24 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('24 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 25 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id25 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
		  --dbms_output.put_line('25 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 26 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id26 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('26 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 27 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id27 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('27 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 28 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id28 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('28 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 29 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id29 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('29 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);

	    when 30 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id30 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('30 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 31 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id31 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('31 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 32 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id32 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('32 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 33 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id33 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('33 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 34 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id34 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('34 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 35 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id35 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
		  --dbms_output.put_line('35 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 36 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id36 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('36 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 37 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id37 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('37 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 38 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id38 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('38 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 39 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id39 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
		--dbms_output.put_line('39 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 40 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id40 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('40 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 41 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id41 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('41 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 42 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id42 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('42 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 43 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id43 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('43 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 44 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id44 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('44 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 45 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id45 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
		--dbms_output.put_line('45 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 46 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id46 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('46 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 47 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id47 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('47 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 48 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id48 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('48 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 49 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id49 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
		--dbms_output.put_line('49 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 50 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id50 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('50 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 51 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id51 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('51 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 52 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id52 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('52 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 53 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id53 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('53 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 54 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id54 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('54 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 55 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id55 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
		--dbms_output.put_line('55 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 56 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id56 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('56 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 57 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id57 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('57 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 58 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id58 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('58 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 59 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id59 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
		--dbms_output.put_line('59 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 60 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id60 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('60 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 61 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id61 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('61 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 62 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id62 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('62 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 63 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id63 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('63 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 64 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id64 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('64 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 65 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id65 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
		--dbms_output.put_line('65 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 66 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id66 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('66 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 67 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id67 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('67 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 68 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id68 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('68 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 69 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id69 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
		--dbms_output.put_line('69 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);

	    when 70 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id70 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('70 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 71 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id71 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('71 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 72 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id72 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('72 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 73 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id73 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('73 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 74 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id74 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
    	  --dbms_output.put_line('74 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);
	    when 75 then
          forall j in l_terr_qual_rec.lay_seq_num.first..l_terr_qual_rec.lay_seq_num.last
   	        update JTY_WEBADI_OTH_TERR_INTF jwot
   	    	set jwot.terr_qual_id75 = l_Terr_Qual_Rec.TERR_QUAL_ID(j)
    	  	where jwot.lay_seq_num = l_terr_qual_rec.lay_seq_num(j)
    	      and jwot.header = p_header
    		  and jwot.user_sequence = p_user_sequence
    		  and jwot.interface_type = p_intf_type
    		  and jwot.status is null;
		--dbms_output.put_line('75 Update terr_qual_id, actual row processed:  '||SQL%ROWCOUNT);

		else null;
		end case;
	end if;
  end loop;

  --Bug 7622791 : Updating all the entries (Excpet the first) with action_flag 'C' (Create) to 'U' (Update) will mean the newly created entry needs to be updated.
  --This is wrong as update will not happen as its a new entry and need to created (Inserted).
  /*
  UPDATE JTY_WEBADI_OTH_TERR_INTF jwot
    SET ACTION_FLAG = 'U'
    WHERE LAY_SEQ_NUM not in
	  ( SELECT MIN(jwot2.LAY_SEQ_NUM)
	    FROM JTY_WEBADI_OTH_TERR_INTF jwot2
    	WHERE jwot.ACTION_FLAG = jwot2.ACTION_FLAG
    	and jwot.header = jwot2.header
    	AND jwot.USER_SEQUENCE = jwot2.USER_SEQUENCE
    	AND jwot.interface_type = jwot2.interface_type
		AND jwot.ACTION_FLAG = jwot2.action_flag
    	group by jwot.terr_id)
    AND jwot.ACTION_FLAG = 'C'
    and jwot.header = p_header
    AND jwot.USER_SEQUENCE = p_user_sequence
    AND jwot.interface_type = p_intf_type;
	*/

END UPDATE_TERR_QUAL_ID;

PROCEDURE delete_records(
  P_USER_SEQUENCE 		 IN NUMBER,
  P_INTF_TYPE			 IN VARCHAR2,
  p_action_flag			 IN VARCHAR2)
IS

  cursor get_del_terr_csr(
  v_user_sequence 		  number,
  v_action_flag			  varchar2,
  v_intf_type			  varchar2,
  v_header				  varchar2
  ) IS
  SELECT TERR_ID, lay_seq_num
      FROM JTY_WEBADI_OTH_TERR_INTF
      WHERE interface_type = v_intf_type
        AND action_flag = v_action_flag
		AND user_sequence = v_user_sequence
		AND header = v_header
        AND status IS NULL;

  cursor get_del_qual_csr(
  v_user_sequence 		  number,
  v_action_flag			  varchar2,
  v_intf_type			  varchar2,
  v_header				  varchar2
  ) IS
  select sub.terr_qual_id, sub.lay_seq_num
	from ( select terr_qual_id1 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual1_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id2 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual2_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id3 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual3_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id4 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual4_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id5 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual5_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id6 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual6_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id7 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual7_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id8 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual8_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id9 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual9_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id10 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual10_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id11 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual11_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id12 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual12_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id13 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual13_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id14 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual14_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id15 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual15_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id16 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual16_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id17 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual17_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id18 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual18_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id19 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual19_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id20 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual20_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id21 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual21_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id22 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual22_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id23 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual23_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id24 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual24_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id25 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual25_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id26 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual26_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id27 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual27_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id28 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual28_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id29 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual29_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id30 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual30_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id31 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual31_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id32 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual32_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id33 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual33_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id34 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual34_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id35 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual35_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id36 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual36_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id37 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual37_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id38 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual38_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id39 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual39_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id40 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual40_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id41 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual41_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id42 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual42_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id43 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual43_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id44 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual44_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id45 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual45_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id46 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual46_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id47 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual47_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id48 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual48_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id49 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual49_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id50 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual50_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id51 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual51_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id52 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual52_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id53 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual53_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id54 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual54_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id55 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual55_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id56 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual56_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id57 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual57_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id58 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual58_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id59 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual59_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id60 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual60_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id61 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual61_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id62 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual62_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id63 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual63_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id64 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual64_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id65 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual65_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id66 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual66_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id67 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual67_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id68 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual68_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id69 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual69_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id70 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual70_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id71 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual71_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id72 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual72_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id73 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual73_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id74 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual74_value_id is not null
   	   		  and jwot.status is null
			union all
			select terr_qual_id75 terr_qual_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual75_value_id is not null
   	   		  and jwot.status is null
			  ) sub;

 cursor get_del_qual_val_csr(
  v_user_sequence 		  number,
  v_action_flag			  varchar2,
  v_intf_type			  varchar2,
  v_header				  varchar2
  ) IS
  select sub.qual_value_id, sub.lay_seq_num
	from ( select qual1_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual1_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual2_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual2_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual3_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual3_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual4_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual4_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual5_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual5_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual6_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual6_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual7_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual7_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual8_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual8_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual9_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual9_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual10_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual10_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual11_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual11_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual12_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual12_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual13_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual13_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual14_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual14_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual15_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual15_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual16_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual16_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual17_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual17_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual18_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual18_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual19_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual19_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual20_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual20_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual21_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual21_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual22_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual22_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual23_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual23_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual24_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual24_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual25_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual25_value_id is not null
   	   		  and jwot.status is null
			  union all
			select qual26_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual26_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual27_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual27_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual28_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual28_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual29_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual29_value_id is not null
   	   		  and jwot.status is null
			union all

			select qual30_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual30_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual31_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual31_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual32_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual32_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual33_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual33_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual34_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual34_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual35_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual35_value_id is not null
   	   		  and jwot.status is null
			  union all
			select qual36_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual36_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual37_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual37_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual38_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual38_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual39_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual39_value_id is not null
   	   		  and jwot.status is null
			union all

			select qual40_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual40_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual41_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual41_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual42_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual42_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual43_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual43_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual44_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual44_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual45_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual45_value_id is not null
   	   		  and jwot.status is null
			  union all
			select qual46_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual46_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual47_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual47_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual48_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual48_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual49_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual49_value_id is not null
   	   		  and jwot.status is null
			union all

			select qual50_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual50_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual51_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual51_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual52_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual52_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual53_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual53_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual54_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual54_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual55_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual55_value_id is not null
   	   		  and jwot.status is null
			  union all
			select qual56_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual56_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual57_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual57_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual58_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual58_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual59_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual59_value_id is not null
   	   		  and jwot.status is null
			union all

			select qual60_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual60_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual61_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual61_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual62_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual62_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual63_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual63_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual64_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual64_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual65_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual65_value_id is not null
   	   		  and jwot.status is null
			  union all
			select qual66_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual66_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual67_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual67_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual68_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual68_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual69_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual69_value_id is not null
   	   		  and jwot.status is null
			union all

			select qual70_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual70_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual71_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual71_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual72_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual72_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual73_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual73_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual74_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual74_value_id is not null
   	   		  and jwot.status is null
			union all
			select qual75_value_id qual_value_id, lay_seq_num
  	 	  	from JTY_WEBADI_OTH_TERR_INTF jwot
   	 		WHERE jwot.user_sequence = v_user_sequence
   	   		  and jwot.action_flag = v_action_flag
   	   		  and jwot.interface_type = v_intf_type
   	   		  and jwot.header		   = v_header
			  and jwot.qual75_value_id is not null
   	   		  and jwot.status is null
			  ) sub;

  cursor get_del_rsc_csr(
  v_user_sequence 		  number,
  v_action_flag			  varchar2,
  v_intf_type			  varchar2,
  v_header				  varchar2
  ) IS
  SELECT jwr.TERR_RSC_ID, jwot.lay_seq_num
      FROM JTY_WEBADI_OTH_TERR_INTF jwot,
	  JTY_WEBADI_RESOURCES jwr
      WHERE jwot.lay_seq_num = jwr.lay_seq_num
		and jwot.header = jwr.header
		and jwot.user_sequence = jwr.user_sequence
		AND jwot.interface_type = jwr.interface_type
	    AND jwot.interface_type = v_intf_type
        AND jwot.action_flag = v_action_flag
		AND jwot.user_sequence = v_user_sequence
		AND jwot.header = v_header
        AND jwot.status IS NULL;

  TYPE DEL_TERR_REC_TYPE is RECORD
  ( terr_id				 number_tbl_type,
    lay_seq_num			 number_tbl_type);

  TYPE DEL_QUAL_REC_TYPE is RECORD
  ( terr_qual_id			 number_tbl_type,
	lay_seq_num				 number_tbl_type);

  TYPE DEL_QUAL_VAL_REC_TYPE is RECORD
  ( qual_value_id			 number_tbl_type,
	lay_seq_num				 number_tbl_type);

  TYPE DEL_RSC_REC_TYPE is RECORD
  ( terr_rsc_id			 number_tbl_type,
	lay_seq_num			 number_tbl_type);

  l_del_terr_rec		 del_terr_rec_type;
  l_del_qual_rec		 del_qual_rec_type;
  l_del_rsc_rec		 	 del_rsc_rec_type;
  l_del_qual_val_rec		 del_qual_val_rec_type;

  l_header		varchar2(15);
  l_row_count	number;
  l_intf_type	VARCHAR2(1);
  l_count		NUMBER;
  l_api_version_number      CONSTANT NUMBER   := 1.0;
  x_return_status	 varchar2(255);
  X_Msg_Count		 number;
  X_Msg_Data		 varchar2(255);
  l_qual_values_count number;

BEGIN

  -- process territory deletion
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_header := 'TERR';
  open get_del_terr_csr(p_user_sequence, p_action_flag, p_intf_type, l_header);
  fetch get_del_terr_csr bulk collect into l_del_terr_rec.terr_id, l_del_terr_rec.lay_seq_num;
  close get_del_terr_csr;

  if l_del_terr_rec.terr_id.count > 0 then
  BEGIN
    forall i in l_del_terr_rec.terr_id.first..l_del_terr_rec.terr_id.last
	--Delete Territory Values
	  DELETE from JTF_TERR_VALUES_ALL WHERE TERR_QUAL_ID IN
          ( SELECT TERR_QUAL_ID FROM JTF_TERR_QUAL_ALL
		  	WHERE TERR_ID = l_del_terr_rec.terr_id(i) );

    forall i in l_del_terr_rec.terr_id.first..l_del_terr_rec.terr_id.last
    --Delete Territory Qualifer records
      DELETE from JTF_TERR_QUAL_ALL WHERE TERR_ID = l_del_terr_rec.terr_id(i);

    forall i in l_del_terr_rec.terr_id.first..l_del_terr_rec.terr_id.last
    --Delete Territory qual type usgs
      DELETE from JTF_TERR_QTYPE_USGS_ALL WHERE TERR_ID = l_del_terr_rec.terr_id(i);

    forall i in l_del_terr_rec.terr_id.first..l_del_terr_rec.terr_id.last
    --Delete Territory usgs
      DELETE from JTF_TERR_USGS_ALL WHERE TERR_ID = l_del_terr_rec.terr_id(i);

    forall i in l_del_terr_rec.terr_id.first..l_del_terr_rec.terr_id.last
    --Delete Territory Resource Access
      DELETE from JTF_TERR_RSC_ACCESS_ALL WHERE TERR_RSC_ID IN
          ( SELECT TERR_RSC_ID FROM JTF_TERR_RSC_ALL
		  	WHERE TERR_ID = l_del_terr_rec.terr_id(i) );

    forall i in l_del_terr_rec.terr_id.first..l_del_terr_rec.terr_id.last
    --Delete the Territory Resource records
      DELETE from JTF_TERR_RSC_ALL Where TERR_ID = l_del_terr_rec.terr_id(i);

    forall i in l_del_terr_rec.terr_id.first..l_del_terr_rec.terr_id.last
    --Delete Territory record
      DELETE from JTF_TERR_ALL WHERE TERR_ID = l_del_terr_rec.terr_id(i);

	-- update all records including the qual and rsc which will be deleted
    forall i in l_del_terr_rec.terr_id.first..l_del_terr_rec.terr_id.last
      update JTY_WEBADI_OTH_TERR_INTF
	  set status = x_return_status
	  where terr_id = l_del_terr_rec.terr_id(i)
	    and user_sequence = p_user_sequence
	    and interface_type = p_intf_type;

	EXCEPTION
	  when others then
        x_return_status := FND_API.G_RET_STS_ERROR;
		fnd_message.clear;
        fnd_message.set_name ('JTF', 'JTY_OTH_TERR_DELETE_TERR');
        X_Msg_Data := fnd_message.get();

    	forall i in l_del_terr_rec.lay_seq_num.first..l_del_terr_rec.lay_seq_num.last
	    update JTY_WEBADI_OTH_TERR_INTF
		set status = x_return_status,
		error_msg = x_msg_data
		where lay_seq_num = l_del_terr_rec.lay_seq_num(i)
		  and user_sequence = p_user_sequence
		  and interface_type = p_intf_type;
  END;
  end if;

  -- process qualifier deletion
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_header := 'QUAL';
 open get_del_qual_val_csr(p_user_sequence, p_action_flag, p_intf_type, l_header);
  fetch get_del_qual_val_csr bulk collect into
    l_del_qual_val_rec.qual_value_id, l_del_qual_val_rec.lay_seq_num;
  close get_del_qual_val_csr;

  if l_del_qual_val_rec.qual_value_id.count > 0 then
    BEGIN
	  FORALL i in l_del_qual_val_rec.qual_value_id.first..l_del_qual_val_rec.qual_value_id.last
            DELETE FROM JTF_TERR_VALUES_ALL
    	WHERE TERR_VALUE_ID = l_del_qual_val_rec.qual_value_id(i);

       FOR l_del_qual_rec in get_del_qual_csr(p_user_sequence, p_action_flag, p_intf_type, l_header)
          Loop
                SELECT COUNT(*) INTO l_qual_values_count FROM JTF_TERR_VALUES_ALL WHERE TERR_QUAL_ID = l_del_qual_rec.terr_qual_id;
                IF l_qual_values_count = 0 THEN
                  DELETE from JTF_TERR_QUAL_ALL jtq
                  WHERE jtq.terr_qual_id = l_del_qual_rec.terr_qual_id;
                END IF;
         END Loop;

      forall i in l_del_qual_val_rec.lay_seq_num.first..l_del_qual_val_rec.lay_seq_num.last
	    update JTY_WEBADI_OTH_TERR_INTF
		set status = x_return_status
		where lay_seq_num = l_del_qual_val_rec.lay_seq_num(i)
		  and user_sequence = p_user_sequence
		  and action_flag = p_action_flag
		  and header = l_header
		  and interface_type = p_intf_type;

	EXCEPTION
	  when others then
        x_return_status := FND_API.G_RET_STS_ERROR;
		fnd_message.clear;
        fnd_message.set_name ('JTF', 'JTY_OTH_TERR_DELETE_QUAL');
        X_Msg_Data := fnd_message.get();

    	forall i in l_del_qual_val_rec.lay_seq_num.first..l_del_qual_val_rec.lay_seq_num.last
	    update JTY_WEBADI_OTH_TERR_INTF
		set status = x_return_status,
		error_msg = x_msg_data
		where lay_seq_num = l_del_qual_val_rec.lay_seq_num(i)
		  and user_sequence = p_user_sequence
		  and action_flag = p_action_flag
		  and header = l_header
		  and interface_type = p_intf_type;
	END;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_header := 'RSC';
  open get_del_rsc_csr(p_user_sequence, p_action_flag, p_intf_type, l_header);
  fetch get_del_rsc_csr bulk collect into
    l_del_rsc_rec.terr_rsc_id, l_del_rsc_rec.lay_seq_num;
  close get_del_rsc_csr;

  if l_del_rsc_rec.terr_rsc_id.count > 0 then
    BEGIN
    --Delete Territory Resource Access
      forall i in l_del_rsc_rec.terr_rsc_id.first..l_del_rsc_rec.terr_rsc_id.last
        DELETE FROM JTF_TERR_RSC_ACCESS_ALL
	    WHERE TERR_RSC_ID = l_del_rsc_rec.terr_rsc_id(i);

    -- Delete the Territory Resource records
      forall i in l_del_rsc_rec.terr_rsc_id.first..l_del_rsc_rec.terr_rsc_id.last
        DELETE FROM JTF_TERR_RSC_ALL
	    WHERE TERR_RSC_ID = l_del_rsc_rec.terr_rsc_id(i);

      forall i in l_del_rsc_rec.lay_seq_num.first..l_del_rsc_rec.lay_seq_num.last
	    update JTY_WEBADI_OTH_TERR_INTF
		set status = x_return_status
		where lay_seq_num = l_del_rsc_rec.lay_seq_num(i)
		  and user_sequence = p_user_sequence
		  and action_flag = p_action_flag
		  and header = l_header
		  and interface_type = p_intf_type;

	EXCEPTION
	  when others then
        x_return_status := FND_API.G_RET_STS_ERROR;
		fnd_message.clear;
        fnd_message.set_name ('JTF', 'JTY_OTH_TERR_DELETE_RSC');
        X_Msg_Data := fnd_message.get();

    	forall i in l_del_rsc_rec.lay_seq_num.first..l_del_rsc_rec.lay_seq_num.last
	    update JTY_WEBADI_OTH_TERR_INTF
		set status = x_return_status,
		error_msg = x_msg_data
		where lay_seq_num = l_del_rsc_rec.lay_seq_num(i)
		  and user_sequence = p_user_sequence
		  and action_flag = p_action_flag
		  and header = l_header
		  and interface_type = p_intf_type;
	END;
  end if;

END delete_records;

PROCEDURE INSERT_TERR_QUAL(
  p_terr_qual_rec 			IN OUT NOCOPY  Terr_Qual_Rec_Type,
  x_return_status			OUT NOCOPY	 VARCHAR2,
  x_msg_data				OUT NOCOPY	 VARCHAR2
) IS
	l_OVERLAP_ALLOWED_FLAG varchar2(1) := 'Y';
	l_terr_qual_rec		   terr_qual_rec_type := p_terr_qual_rec;
BEGIN
  if (l_Terr_Qual_Rec.TERR_ID.count > 0) then
    --dbms_output.put_line('U: get_qual_csr: create MA, rowcount: ' || l_Terr_Qual_Rec.TERR_ID.count);
    forall i in l_Terr_Qual_Rec.TERR_ID.first..l_Terr_Qual_Rec.TERR_ID.last
      INSERT INTO JTF_TERR_QUAL_ALL(
              TERR_QUAL_ID,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_LOGIN,
              TERR_ID,
              QUAL_USG_ID,
              ORG_ID,
			  OVERLAP_ALLOWED_FLAG)
       VALUES (
   	     --JTF_TERR_QUAL_s.nextval,
		 l_Terr_Qual_Rec.TERR_QUAL_ID(i),
   	  	 l_Terr_Qual_Rec.last_update_date(i),
   	  	 l_Terr_Qual_Rec.last_updated_by(i),
   	  	 l_Terr_Qual_Rec.creation_date(i),
   	  	 l_Terr_Qual_Rec.created_by(i),
   	  	 l_Terr_Qual_Rec.last_update_login(i),
   	  	 l_Terr_Qual_Rec.terr_id(i),
   	  	 l_Terr_Qual_Rec.qual_usg_id(i),
   	  	 l_Terr_Qual_Rec.org_id(i),
		 l_OVERLAP_ALLOWED_FLAG );
--	   RETURNING TERR_QUAL_ID bulk collect into l_Terr_Qual_Rec.TERR_QUAL_ID;
	--dbms_output.put_line(' U: get_qual_csr:MA, actual row processed:  '||SQL%ROWCOUNT);

  end if; --get_qual_csr

	EXCEPTION
	  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
		fnd_message.clear;
        fnd_message.set_name ('JTF', 'JTY_OTH_TERR_CREATE_QUAL');
        X_Msg_Data := fnd_message.get();

END INSERT_TERR_QUAL;

PROCEDURE check_duplicate_value(
      p_Terr_Values_Rec IN Terr_values_rec_type,
      x_return_status	OUT NOCOPY	 VARCHAR2,
      x_msg_data	OUT NOCOPY	 VARCHAR2)
AS

l_dummy VARCHAR2(5);
l_terr_values_rec terr_values_rec_type := p_terr_values_rec;

BEGIN

  x_return_status := fnd_api.g_ret_sts_success;

  IF(l_terr_values_rec.terr_qual_id.COUNT > 0) THEN
    FOR i IN l_terr_values_rec.terr_qual_id.FIRST .. l_terr_values_rec.terr_qual_id.LAST
    LOOP
    BEGIN
      SELECT 'X'
      INTO l_dummy
      FROM jtf_terr_values_all
      WHERE terr_qual_id = l_terr_values_rec.terr_qual_id(i)
       AND nvl(comparison_operator,   '-9999') = nvl(l_terr_values_rec.comparison_operator(i),   '-9999')
       AND nvl(low_value_char,   '-9999') = nvl(l_terr_values_rec.low_value_char(i),   '-9999')
       AND nvl(high_value_char,   '-9999') = nvl(l_terr_values_rec.high_value_char(i),   '-9999')
       AND nvl(low_value_number,   -9999) = nvl(l_terr_values_rec.low_value_number(i),   -9999)
       AND nvl(high_value_number,   -9999) = nvl(l_terr_values_rec.high_value_number(i),   -9999)
       AND nvl(interest_type_id,   -9999) = nvl(l_terr_values_rec.interest_type_id(i),   -9999)
       AND nvl(primary_interest_code_id,   -9999) = nvl(l_terr_values_rec.primary_interest_code_id(i),   -9999)
       AND nvl(secondary_interest_code_id,   -9999) = nvl(l_terr_values_rec.secondary_interest_code_id(i),   -9999)
       AND nvl(currency_code,   '-9999') = nvl(l_terr_values_rec.currency_code(i),   '-9999')
       AND nvl(low_value_char_id,   -9999) = nvl(l_terr_values_rec.low_value_char_id(i),   -9999)
       AND nvl(org_id,   -9999) = nvl(l_terr_values_rec.org_id(i),   -9999)
       AND nvl(value1_id,   -9999) = nvl(l_terr_values_rec.value1_id(i),   -9999)
       AND nvl(value2_id,   -9999) = nvl(l_terr_values_rec.value2_id(i),   -9999)
       AND nvl(value3_id,   -9999) = nvl(l_terr_values_rec.value3_id(i),   -9999) ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           NULL;
      END;
    END LOOP;
    IF l_dummy = 'X' THEN
        fnd_message.clear;
        fnd_message.set_name('JTF',   'JTY_DUP_TRANS_ATTR_VAL');
        x_msg_data := fnd_message.GET();
        x_return_status := fnd_api.g_ret_sts_error;
     END IF;
  END IF;

  EXCEPTION --
    WHEN others THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('JTF',   'JTF_TERR_UNEXPECTED_ERROR');
      fnd_message.set_token('PROC_NAME',   'Check_duplicate_Value');
      fnd_message.set_token('ERROR',   sqlerrm);
      x_msg_data := fnd_message.GET();
END;

PROCEDURE check_duplicate_value_update(
      p_Terr_Values_Rec IN Terr_values_rec_type,
      x_return_status	OUT NOCOPY	 VARCHAR2,
      x_msg_data	OUT NOCOPY	 VARCHAR2)
AS

l_dummy VARCHAR2(5) := 'Y';
l_terr_values_rec terr_values_rec_type := p_terr_values_rec;

BEGIN

  x_return_status := fnd_api.g_ret_sts_success;
--test('p_terr_values_rec.terr_qual_id.COUNT', p_terr_values_rec.terr_qual_id.COUNT);
  IF(l_terr_values_rec.terr_qual_id.COUNT > 0) THEN
    FOR i IN l_terr_values_rec.terr_qual_id.FIRST .. l_terr_values_rec.terr_qual_id.LAST
    LOOP

    Begin
     SELECT 'X'
      INTO l_dummy
      FROM jtf_terr_values_all
      WHERE TERR_VALUE_ID <> l_terr_values_rec.TERR_VALUE_ID(i)
       AND terr_qual_id = l_terr_values_rec.terr_qual_id(i)
       AND nvl(comparison_operator,   '-9999') = nvl(l_terr_values_rec.comparison_operator(i),   '-9999')
       AND nvl(low_value_char,   '-9999') = nvl(l_terr_values_rec.low_value_char(i),   '-9999')
       AND nvl(high_value_char,   '-9999') = nvl(l_terr_values_rec.high_value_char(i),   '-9999')
       AND nvl(low_value_number,   -9999) = nvl(l_terr_values_rec.low_value_number(i),   -9999)
       AND nvl(high_value_number,   -9999) = nvl(l_terr_values_rec.high_value_number(i),   -9999)
       AND nvl(interest_type_id,   -9999) = nvl(l_terr_values_rec.interest_type_id(i),   -9999)
       AND nvl(primary_interest_code_id,   -9999) = nvl(l_terr_values_rec.primary_interest_code_id(i),   -9999)
       AND nvl(secondary_interest_code_id,   -9999) = nvl(l_terr_values_rec.secondary_interest_code_id(i),   -9999)
       AND nvl(currency_code,   '-9999') = nvl(l_terr_values_rec.currency_code(i),   '-9999')
       AND nvl(low_value_char_id,   -9999) = nvl(l_terr_values_rec.low_value_char_id(i),   -9999)
       AND nvl(org_id,   -9999) = nvl(l_terr_values_rec.org_id(i),   -9999)
       AND nvl(value1_id,   -9999) = nvl(l_terr_values_rec.value1_id(i),   -9999)
       AND nvl(value2_id,   -9999) = nvl(l_terr_values_rec.value2_id(i),   -9999)
       AND nvl(value3_id,   -9999) = nvl(l_terr_values_rec.value3_id(i),   -9999) ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           NULL;
      END;
    END LOOP;

    IF l_dummy = 'X' THEN
        fnd_message.clear;
        fnd_message.set_name('JTF',   'JTY_DUP_TRANS_ATTR_VAL');
        x_msg_data := fnd_message.GET();
        x_return_status := fnd_api.g_ret_sts_error;
    END IF;
  END IF;

  EXCEPTION --
    WHEN others THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('JTF',   'JTF_TERR_UNEXPECTED_ERROR');
      fnd_message.set_token('PROC_NAME',   'Check_duplicate_Value');
      fnd_message.set_token('ERROR',   sqlerrm);
      x_msg_data := fnd_message.GET();
      --test('x_msg_data', x_msg_data);
END check_duplicate_value_update;

PROCEDURE INSERT_TERR_VALUES (
  p_terr_qual_rec 			IN Terr_Qual_Rec_Type,
  p_terr_values_out_rec		OUT NOCOPY	 Terr_values_out_rec_type,
  x_return_status			OUT NOCOPY	 VARCHAR2,
  x_msg_data				OUT NOCOPY	 VARCHAR2
) IS
  l_Terr_Values_Rec Terr_values_rec_type;
  l_terr_qual_rec Terr_Qual_Rec_Type := p_terr_qual_rec;

BEGIN
  IF (l_Terr_Qual_Rec.TERR_QUAL_ID.count > 0) THEN
    for i in l_Terr_Qual_Rec.TERR_QUAL_ID.first..l_Terr_Qual_Rec.TERR_QUAL_ID.last loop

	   l_Terr_Values_Rec.LAST_UPDATE_DATE(i)  := l_Terr_Qual_Rec.LAST_UPDATE_DATE(i);
	   l_Terr_Values_Rec.LAST_UPDATED_BY(i)   := l_Terr_Qual_Rec.LAST_UPDATED_BY(i);
	   l_Terr_Values_Rec.CREATION_DATE(i) 	  := l_Terr_Qual_Rec.CREATION_DATE(i);
	   l_Terr_Values_Rec.CREATED_BY(i)    	  := l_Terr_Qual_Rec.CREATED_BY(i);
	   l_Terr_Values_Rec.LAST_UPDATE_LOGIN(i) := l_Terr_Qual_Rec.LAST_UPDATE_LOGIN(i);
	   l_Terr_Values_Rec.TERR_QUAL_ID(i)  	  := l_Terr_Qual_Rec.TERR_QUAL_ID(i);
	   l_Terr_Values_Rec.COMPARISON_OPERATOR(i) := l_Terr_Qual_Rec.qual_cond(i);
       l_Terr_Values_Rec.ID_USED_FLAG(i)        := l_Terr_Qual_Rec.CONVERT_TO_ID_FLAG(i);
	   l_Terr_Values_Rec.ORG_ID(i)              := l_Terr_Qual_Rec.ORG_ID(i);
	   l_Terr_Values_Rec.TERR_VALUE_ID(i) := NULL;
        l_Terr_Values_Rec.LOW_VALUE_CHAR(i):= NULL;
        l_Terr_Values_Rec.HIGH_VALUE_CHAR(i):= NULL;
        l_Terr_Values_Rec.LOW_VALUE_NUMBER(i):= NULL;
        l_Terr_Values_Rec.HIGH_VALUE_NUMBER(i):= NULL;
        l_Terr_Values_Rec.INTEREST_TYPE_ID(i):= NULL;
        l_Terr_Values_Rec.PRIMARY_INTEREST_CODE_ID(i):= NULL;
        l_Terr_Values_Rec.SECONDARY_INTEREST_CODE_ID(i):= NULL;
        l_Terr_Values_Rec.CURRENCY_CODE(i):= NULL;
--      l_Terr_Values_Rec.ID_USED_FLAG(i):= NULL;
        l_Terr_Values_Rec.LOW_VALUE_CHAR_ID(i):= NULL;
--        l_Terr_Values_Rec.ORG_ID(i):= NULL;
        l_Terr_Values_Rec.VALUE1_ID(i):= NULL;
        l_Terr_Values_Rec.VALUE2_ID(i):= NULL;
        l_Terr_Values_Rec.VALUE3_ID(i):= NULL;

	   case
	     when l_Terr_Qual_Rec.qual_type(i) = 'CHAR' then
			   --dbms_output.put_line('in ' || l_Terr_Qual_Rec.qual_type(i));
		   IF l_Terr_Qual_Rec.CONVERT_TO_ID_FLAG(i) = 'N' then
			   --dbms_output.put_line('in flag' || l_Terr_Qual_Rec.CONVERT_TO_ID_FLAG(i));
		     l_Terr_Values_Rec.LOW_VALUE_CHAR(i) := l_Terr_Qual_Rec.qual_value1(i);
			 if l_Terr_Qual_Rec.qual_value2.count > 0 then
			   --dbms_output.put_line('in l_Terr_Qual_Rec.qual_value2.count');
		       l_Terr_Values_Rec.HIGH_VALUE_CHAR(i) := l_Terr_Qual_Rec.qual_value2(i);
			   --dbms_output.put_line('value: ' || NVL(l_Terr_Values_Rec.HIGH_VALUE_CHAR(i),'ABCDE'));
			 else l_Terr_Values_Rec.HIGH_VALUE_CHAR(i) := NULL;
			 end if;
		   else
		     l_Terr_Values_Rec.LOW_VALUE_CHAR_ID(i) := l_Terr_Qual_Rec.qual_value1(i);
		   end if;
         when l_Terr_Qual_Rec.qual_type(i) = 'DEP_2FIELDS_1CHAR_1ID' then
		   l_Terr_Values_Rec.LOW_VALUE_CHAR(i) := l_Terr_Qual_Rec.qual_value1(i);
		   if l_Terr_Qual_Rec.qual_value2.count > 0 then
		     l_Terr_Values_Rec.LOW_VALUE_CHAR_ID(i) := l_Terr_Qual_Rec.qual_value2(i);
		   else l_Terr_Values_Rec.LOW_VALUE_CHAR_ID(i) := NULL;
		   end if;
         when l_Terr_Qual_Rec.qual_type(i) in
           ('CHAR_2IDS', 'DEP_2FIELDS', 'DEP_2FIELDS_CHAR_2IDS') then
		   l_Terr_Values_Rec.VALUE1_ID(i) := l_Terr_Qual_Rec.qual_value1(i);
		   if l_Terr_Qual_Rec.qual_value2.count > 0 then
		     l_Terr_Values_Rec.VALUE2_ID(i) := l_Terr_Qual_Rec.qual_value2(i);
		   else l_Terr_Values_Rec.VALUE2_ID(i) := NULL;
		   end if;
         when l_Terr_Qual_Rec.qual_type(i) = 'DEP_3FIELDS_CHAR_3IDS' then
		   l_Terr_Values_Rec.VALUE1_ID(i) := l_Terr_Qual_Rec.qual_value1(i);
		   if l_Terr_Qual_Rec.qual_value2.count > 0 then
		     l_Terr_Values_Rec.VALUE2_ID(i) := l_Terr_Qual_Rec.qual_value2(i);
		   else l_Terr_Values_Rec.VALUE2_ID(i) := NULL;
		   end if;
		   if l_Terr_Qual_Rec.qual_value3.count > 0 then
		     l_Terr_Values_Rec.VALUE3_ID(i) := l_Terr_Qual_Rec.qual_value3(i);
		   else l_Terr_Values_Rec.VALUE3_ID(i) := NULL;
		   end if;
         when l_Terr_Qual_Rec.qual_type(i) = 'INTEREST_TYPE' then
		   l_Terr_Values_Rec.INTEREST_TYPE_ID(i) := l_Terr_Qual_Rec.qual_value1(i);
		   if l_Terr_Qual_Rec.qual_value2.count > 0 then
		     l_Terr_Values_Rec.PRIMARY_INTEREST_CODE_ID(i) := l_Terr_Qual_Rec.qual_value2(i);
		   else l_Terr_Values_Rec.PRIMARY_INTEREST_CODE_ID(i) := NULL;
		   end if;
		   if l_Terr_Qual_Rec.qual_value3.count > 0 then
		     l_Terr_Values_Rec.SECONDARY_INTEREST_CODE_ID(i) := l_Terr_Qual_Rec.qual_value3(i);
		   else l_Terr_Values_Rec.SECONDARY_INTEREST_CODE_ID(i) := NULL;
		   end if;
         when l_Terr_Qual_Rec.qual_type(i) = 'NUMERIC' then
		   l_Terr_Values_Rec.LOW_VALUE_NUMBER(i) := l_Terr_Qual_Rec.qual_value1(i);
		   if l_Terr_Qual_Rec.qual_value2.count > 0 then
		     l_Terr_Values_Rec.HIGH_VALUE_NUMBER(i) := l_Terr_Qual_Rec.qual_value2(i);
		   else l_Terr_Values_Rec.HIGH_VALUE_NUMBER(i) := NULL;
		   end if;
         when l_Terr_Qual_Rec.qual_type(i) = 'CURRENCY' then
		   l_Terr_Values_Rec.LOW_VALUE_NUMBER(i) := l_Terr_Qual_Rec.qual_value1(i);
		   if l_Terr_Qual_Rec.qual_value2.count > 0 then
		     l_Terr_Values_Rec.HIGH_VALUE_NUMBER(i) := l_Terr_Qual_Rec.qual_value2(i);
		   else l_Terr_Values_Rec.HIGH_VALUE_NUMBER(i) := NULL;
		   end if;
		   if l_Terr_Qual_Rec.qual_value3.count > 0 then
		     l_Terr_Values_Rec.CURRENCY_CODE(i) := l_Terr_Qual_Rec.qual_value3(i);
		   else l_Terr_Values_Rec.CURRENCY_CODE(i) := NULL;
		   end if;
         else null;
	   end case;
	   --dbms_output.put_line('case ended');

	end loop;

    --dbms_output.put_line('C: get_qual_csr: create TV, rowcount: ' || l_Terr_Values_Rec.TERR_QUAL_ID.count);
	/*
	for i in l_Terr_Values_Rec.TERR_QUAL_ID.first..l_Terr_Values_Rec.TERR_QUAL_ID.last loop
	  --dbms_output.put_line(l_Terr_Values_Rec.LAST_UPDATED_BY(i)||', '||
        l_Terr_Values_Rec.LAST_UPDATE_DATE(i)||', '||
        l_Terr_Values_Rec.CREATED_BY(i)||', '||
        l_Terr_Values_Rec.CREATION_DATE(i)||', '||
        l_Terr_Values_Rec.LAST_UPDATE_LOGIN(i)||', '||
        l_Terr_Values_Rec.TERR_QUAL_ID(i)||', '||
        l_Terr_Values_Rec.COMPARISON_OPERATOR(i)||', '||
        l_Terr_Values_Rec.LOW_VALUE_CHAR(i)||', '||
        l_Terr_Values_Rec.HIGH_VALUE_CHAR(i)||', '||
        l_Terr_Values_Rec.LOW_VALUE_NUMBER(i)||', '||
        l_Terr_Values_Rec.HIGH_VALUE_NUMBER(i)||', '||
        l_Terr_Values_Rec.INTEREST_TYPE_ID(i)||', '||
        l_Terr_Values_Rec.PRIMARY_INTEREST_CODE_ID(i)||', '||
        l_Terr_Values_Rec.SECONDARY_INTEREST_CODE_ID(i)||', '||
        l_Terr_Values_Rec.CURRENCY_CODE(i)||', '||
        l_Terr_Values_Rec.ID_USED_FLAG(i)||', '||
        l_Terr_Values_Rec.LOW_VALUE_CHAR_ID(i)||', '||
        l_Terr_Values_Rec.ORG_ID(i)||', '||
        l_Terr_Values_Rec.VALUE1_ID(i)||', '||
        l_Terr_Values_Rec.VALUE2_ID(i)||', '||
        l_Terr_Values_Rec.VALUE3_ID(i) );
	end loop;
*/

 --Check for duplicate values.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

	Check_duplicate_Value(
          p_Terr_Values_Rec => l_Terr_Values_Rec ,
	  x_return_status   => x_return_status,
	  x_msg_data        => x_msg_data );


        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
          forall i in l_Terr_Values_Rec.TERR_QUAL_ID.first..l_Terr_Values_Rec.TERR_QUAL_ID.last
        INSERT INTO JTF_TERR_VALUES_ALL(
          TERR_VALUE_ID,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATE_LOGIN,
          TERR_QUAL_ID,
          COMPARISON_OPERATOR,
          LOW_VALUE_CHAR,
          HIGH_VALUE_CHAR,
          LOW_VALUE_NUMBER,
          HIGH_VALUE_NUMBER,
          INTEREST_TYPE_ID,
          PRIMARY_INTEREST_CODE_ID,
          SECONDARY_INTEREST_CODE_ID,
          CURRENCY_CODE,
          ID_USED_FLAG,
          LOW_VALUE_CHAR_ID,
          ORG_ID,
          VALUE1_ID,
          VALUE2_ID,
          VALUE3_ID
         )
            VALUES (
          JTF_TERR_VALUES_s.nextval,
          l_Terr_Values_Rec.LAST_UPDATED_BY(i),
          l_Terr_Values_Rec.LAST_UPDATE_DATE(i),
          l_Terr_Values_Rec.CREATED_BY(i),
          l_Terr_Values_Rec.CREATION_DATE(i),
          l_Terr_Values_Rec.LAST_UPDATE_LOGIN(i),
          l_Terr_Values_Rec.TERR_QUAL_ID(i),
          l_Terr_Values_Rec.COMPARISON_OPERATOR(i),
          l_Terr_Values_Rec.LOW_VALUE_CHAR(i),
          l_Terr_Values_Rec.HIGH_VALUE_CHAR(i),
          l_Terr_Values_Rec.LOW_VALUE_NUMBER(i),
          l_Terr_Values_Rec.HIGH_VALUE_NUMBER(i),
          l_Terr_Values_Rec.INTEREST_TYPE_ID(i),
          l_Terr_Values_Rec.PRIMARY_INTEREST_CODE_ID(i),
          l_Terr_Values_Rec.SECONDARY_INTEREST_CODE_ID(i),
          l_Terr_Values_Rec.CURRENCY_CODE(i),
          l_Terr_Values_Rec.ID_USED_FLAG(i),
          l_Terr_Values_Rec.LOW_VALUE_CHAR_ID(i),
          l_Terr_Values_Rec.ORG_ID(i),
          l_Terr_Values_Rec.VALUE1_ID(i),
          l_Terr_Values_Rec.VALUE2_ID(i),
          l_Terr_Values_Rec.VALUE3_ID(i)
         ) RETURNING TERR_VALUE_ID,TERR_QUAL_ID
             BULK COLLECT INTO p_terr_values_out_rec.TERR_VALUE_ID,
                          p_terr_values_out_rec.TERR_QUAL_ID;

	--dbms_output.put_line(' C: get_qual_csr:TV, actual row processed:  '||SQL%ROWCOUNT);

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;
  END IF; -- TERR_QUAL_ID count
	EXCEPTION
	  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
		fnd_message.clear;
        fnd_message.set_name ('JTF', 'JTY_OTH_TERR_CREATE_QUAL_VAL');
        X_Msg_Data := fnd_message.get();

		--dbms_output.put_line(sqlerrm);

END INSERT_TERR_VALUES;

PROCEDURE UPDATE_TERR(
  p_user_sequence IN number,
  p_action_flag	  IN varchar2,
  x_return_status OUT NOCOPY varchar2,
  x_msg_data	  OUT NOCOPY varchar2
) IS

  CURSOR get_terr_all_csr (
    v_user_sequence		 number,
    v_header			 varchar2,
	v_action_flag		 varchar2,
	v_intf_type			 varchar2) IS
	Select
		NVL(TERR_ID,JTF_TERR_s.nextval) TERR_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
		'JTF' APPLICATION_SHORT_NAME,
        TERR_NAME NAME,
        'Y' ENABLED_FLAG,
        NVL(TERR_START_DATE,TRUNC(SYSDATE)) START_DATE_ACTIVE,
        RANK,
        NVL(TERR_END_DATE, ADD_MONTHS(NVL(TERR_START_DATE,TRUNC(SYSDATE)), 12) )END_DATE_ACTIVE,
        TERR_NAME DESCRIPTION,
        'Y' UPDATE_FLAG,
        TERR_TYPE_ID TERRITORY_TYPE_ID,
        PARENT_TERR_ID PARENT_TERRITORY_ID,
        'N' TEMPLATE_FLAG,
        'N' ESCALATION_TERRITORY_FLAG,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        ORG_ID,
        NUM_WINNERS,
        0 NUM_QUAL,
	lay_seq_num
        , trim(HIERARCHY) terr_hierarchy
	from JTY_WEBADI_OTH_TERR_INTF
	where header = v_header
	  and status is null
	  and USER_SEQUENCE = v_USER_SEQUENCE
	  and INTERFACE_TYPE = v_intf_type
	  and action_flag = v_action_flag;

TYPE Terr_All_Rec_Type  IS RECORD
  (TERR_ID                     number_tbl_type,
   LAST_UPDATE_DATE            date_tbl_type,
   LAST_UPDATED_BY             number_tbl_type,
   CREATION_DATE               date_tbl_type,
   CREATED_BY                  number_tbl_type,
   LAST_UPDATE_LOGIN           number_tbl_type,
   APPLICATION_SHORT_NAME      varchar2_tbl_type,
   NAME                        var_2000_tbl_type,
   ENABLED_FLAG                var_1_tbl_type,
   START_DATE_ACTIVE           date_tbl_type,
   RANK                        number_tbl_type,
   END_DATE_ACTIVE             date_tbl_type,
   DESCRIPTION                 varchar2_tbl_type,
   UPDATE_FLAG                 var_1_tbl_type,
   TERRITORY_TYPE_ID           number_tbl_type,
   PARENT_TERRITORY_ID         number_tbl_type,
   TEMPLATE_FLAG               var_1_tbl_type,
   ESCALATION_TERRITORY_FLAG   var_1_tbl_type,
   ATTRIBUTE_CATEGORY          varchar2_tbl_type,
   ATTRIBUTE1                  varchar2_tbl_type,
   ATTRIBUTE2                  varchar2_tbl_type,
   ATTRIBUTE3                  varchar2_tbl_type,
   ATTRIBUTE4                  varchar2_tbl_type,
   ATTRIBUTE5                  varchar2_tbl_type,
   ATTRIBUTE6                  varchar2_tbl_type,
   ATTRIBUTE7                  varchar2_tbl_type,
   ATTRIBUTE8                  varchar2_tbl_type,
   ATTRIBUTE9                  varchar2_tbl_type,
   ATTRIBUTE10                 varchar2_tbl_type,
   ATTRIBUTE11                 varchar2_tbl_type,
   ATTRIBUTE12                 varchar2_tbl_type,
   ATTRIBUTE13                 varchar2_tbl_type,
   ATTRIBUTE14                 varchar2_tbl_type,
   ATTRIBUTE15                 varchar2_tbl_type,
   ORG_ID                      number_tbl_type ,
   NUM_WINNERS                 number_tbl_type,
   NUM_QUAL                    number_tbl_type,
   LAY_SEQ_NUM		       number_tbl_type,
   terr_hierarchy              varchar2_tbl_type
  );

  l_terr_all_rec			 Terr_All_Rec_Type;
  l_header varchar2(15) := 'TERR';
  l_intf_type	varchar2(1) := 'U';

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  open get_terr_all_csr( p_user_sequence, l_header,	p_action_flag, l_intf_type);
  fetch get_terr_all_csr bulk collect into l_terr_all_rec.TERR_ID,
        l_terr_all_rec.LAST_UPDATE_DATE, l_terr_all_rec.LAST_UPDATED_BY,
        l_terr_all_rec.CREATION_DATE,  l_terr_all_rec.CREATED_BY,
        l_terr_all_rec.LAST_UPDATE_LOGIN, l_terr_all_rec.APPLICATION_SHORT_NAME,
        l_terr_all_rec.NAME,  l_terr_all_rec.ENABLED_FLAG,
        l_terr_all_rec.START_DATE_ACTIVE, l_terr_all_rec.RANK,
        l_terr_all_rec.END_DATE_ACTIVE,   l_terr_all_rec.DESCRIPTION,
        l_terr_all_rec.UPDATE_FLAG,       l_terr_all_rec.TERRITORY_TYPE_ID,
        l_terr_all_rec.PARENT_TERRITORY_ID,  l_terr_all_rec.TEMPLATE_FLAG,
        l_terr_all_rec.ESCALATION_TERRITORY_FLAG,  l_terr_all_rec.ATTRIBUTE_CATEGORY,
        l_terr_all_rec.ATTRIBUTE1, l_terr_all_rec.ATTRIBUTE2, l_terr_all_rec.ATTRIBUTE3,
        l_terr_all_rec.ATTRIBUTE4, l_terr_all_rec.ATTRIBUTE5, l_terr_all_rec.ATTRIBUTE6,
        l_terr_all_rec.ATTRIBUTE7, l_terr_all_rec.ATTRIBUTE8, l_terr_all_rec.ATTRIBUTE9,
        l_terr_all_rec.ATTRIBUTE10,l_terr_all_rec.ATTRIBUTE11,l_terr_all_rec.ATTRIBUTE12,
        l_terr_all_rec.ATTRIBUTE13,l_terr_all_rec.ATTRIBUTE14,l_terr_all_rec.ATTRIBUTE15,
        l_terr_all_rec.ORG_ID, l_terr_all_rec.NUM_WINNERS, l_terr_all_rec.NUM_QUAL,
		l_terr_all_rec.lay_seq_num, l_terr_all_rec.terr_hierarchy;
  close get_terr_all_csr;

  if (p_action_flag = 'C' and l_terr_all_rec.NAME.count > 0) then
     --forall i in l_terr_all_rec.NAME.first..l_terr_all_rec.NAME.last
     for i in l_terr_all_rec.NAME.first..l_terr_all_rec.NAME.last LOOP
      INSERT INTO JTF_TERR_ALL(
           TERR_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
           CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
           APPLICATION_SHORT_NAME, NAME, ENABLED_FLAG,
           START_DATE_ACTIVE, RANK, END_DATE_ACTIVE, DESCRIPTION,
		   UPDATE_FLAG, TERRITORY_TYPE_ID, PARENT_TERRITORY_ID,
           TEMPLATE_FLAG, ESCALATION_TERRITORY_FLAG, ATTRIBUTE_CATEGORY,
           ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3,
           ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6,
           ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9,
           ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12,
           ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15,
           ORG_ID, NUM_WINNERS, NUM_QUAL
          ) VALUES (
          l_terr_all_rec.TERR_ID(i),
		  l_terr_all_rec.LAST_UPDATE_DATE(i), l_terr_all_rec.LAST_UPDATED_BY(i),
          l_terr_all_rec.CREATION_DATE(i),  l_terr_all_rec.CREATED_BY(i),
          l_terr_all_rec.LAST_UPDATE_LOGIN(i), l_terr_all_rec.APPLICATION_SHORT_NAME(i),
          l_terr_all_rec.NAME(i),  l_terr_all_rec.ENABLED_FLAG(i),
          l_terr_all_rec.START_DATE_ACTIVE(i), l_terr_all_rec.RANK(i),
          l_terr_all_rec.END_DATE_ACTIVE(i),   l_terr_all_rec.DESCRIPTION(i),
          l_terr_all_rec.UPDATE_FLAG(i),       l_terr_all_rec.TERRITORY_TYPE_ID(i),
          l_terr_all_rec.PARENT_TERRITORY_ID(i),  l_terr_all_rec.TEMPLATE_FLAG(i),
          l_terr_all_rec.ESCALATION_TERRITORY_FLAG(i),  l_terr_all_rec.ATTRIBUTE_CATEGORY(i),
          l_terr_all_rec.ATTRIBUTE1(i), l_terr_all_rec.ATTRIBUTE2(i), l_terr_all_rec.ATTRIBUTE3(i),
          l_terr_all_rec.ATTRIBUTE4(i), l_terr_all_rec.ATTRIBUTE5(i), l_terr_all_rec.ATTRIBUTE6(i),
          l_terr_all_rec.ATTRIBUTE7(i), l_terr_all_rec.ATTRIBUTE8(i), l_terr_all_rec.ATTRIBUTE9(i),
          l_terr_all_rec.ATTRIBUTE10(i),l_terr_all_rec.ATTRIBUTE11(i),l_terr_all_rec.ATTRIBUTE12(i),
          l_terr_all_rec.ATTRIBUTE13(i),l_terr_all_rec.ATTRIBUTE14(i),l_terr_all_rec.ATTRIBUTE15(i),
          l_terr_all_rec.ORG_ID(i), l_terr_all_rec.NUM_WINNERS(i), l_terr_all_rec.NUM_QUAL(i));

          if ( l_terr_all_rec.PARENT_TERRITORY_ID(i) = 1 AND l_terr_all_rec.terr_hierarchy(i) IS NOT NULL) THEN
              populate_parent_id(
                  p_user_sequence => p_user_sequence,
                  p_intf_type     => l_intf_type,
                  p_hierarchy     => l_terr_all_rec.terr_hierarchy(i),
                  p_org_id        => l_terr_all_rec.ORG_ID(i),
                  p_terr_id       => l_terr_all_rec.TERR_ID(i),
                  p_terr_name     => l_terr_all_rec.name(i),
                  x_return_status => x_return_status,
                  x_msg_data      => x_msg_data);
          END IF;
        END LOOP;

	forall i in l_terr_all_rec.TERR_ID.first..l_terr_all_rec.TERR_ID.last
	  update JTY_WEBADI_OTH_TERR_INTF
         set parent_terr_id = l_terr_all_rec.terr_id(i)
       where parent_terr_name = l_terr_all_rec.name(i)
         and USER_SEQUENCE = P_USER_SEQUENCE
         and interface_type = l_intf_type
         and parent_terr_id is null;

	forall i in l_terr_all_rec.TERR_ID.first..l_terr_all_rec.TERR_ID.last
      update JTY_WEBADI_OTH_TERR_INTF
      set terr_id = l_terr_all_rec.terr_id(i)
      where terr_name = l_terr_all_rec.name(i)
        and USER_SEQUENCE = P_USER_SEQUENCE
        and interface_type = l_intf_type
        and action_flag = p_action_flag;

    INSERT INTO JTF_TERR_USGS_ALL(
           TERR_USG_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           TERR_ID,
           SOURCE_ID,
           ORG_ID
          )
	SELECT
		JTF_TERR_USGS_s.nextval TERR_USG_ID,
    	LAST_UPDATE_DATE,
    	LAST_UPDATED_BY,
    	CREATION_DATE,
    	CREATED_BY,
    	LAST_UPDATE_LOGIN,
    	TERR_ID,
    	usage_id SOURCE_ID,
    	ORG_ID
	from JTY_WEBADI_OTH_TERR_INTF
	where header = l_header
	  and status is null
	  and USER_SEQUENCE = p_USER_SEQUENCE
	  and INTERFACE_TYPE = l_intf_type
	  and action_flag = p_action_flag;

    INSERT INTO JTF_TERR_QTYPE_USGS_ALL(
           TERR_QTYPE_USG_ID,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           TERR_ID,
           QUAL_TYPE_USG_ID,
           ORG_ID
          )
	  select
	    JTF_TERR_QTYPE_USGS_s.nextval TERR_QUAL_TYPE_USG_ID,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		TERR_ID,
		QUAL_TYPE_ID QUAL_TYPE_USG_ID,
		ORG_ID
	  from JTY_WEBADI_QUAL_TYPE_HEADER gt,
	  JTY_WEBADI_OTH_TERR_INTF jut
 	  where jut.header = L_header
	    and jut.status is null
	    and jut.USER_SEQUENCE = P_USER_SEQUENCE
	    and jut.INTERFACE_TYPE = l_intf_type
		and jut.action_flag = p_action_flag
	    and gt.user_sequence = jut.user_sequence;

	forall i in l_terr_all_rec.lay_seq_num.first..l_terr_all_rec.lay_seq_num.last
		update JTY_WEBADI_OTH_TERR_INTF
		set status = x_return_status
		, error_msg = X_Msg_Data
		where lay_seq_num = l_terr_all_rec.lay_seq_num(i)
		and interface_type = l_intf_type
		and header = l_header
		and user_sequence = p_user_sequence;

  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  if (p_action_flag = 'U' and l_terr_all_rec.TERR_ID.count > 0) then

    forall i in l_terr_all_rec.TERR_ID.first..l_terr_all_rec.TERR_ID.last
    Update JTF_TERR_ALL
    SET
      LAST_UPDATE_DATE = l_terr_all_rec.LAST_UPDATE_DATE(i),
      LAST_UPDATED_BY = l_terr_all_rec.LAST_UPDATED_BY(i),
      LAST_UPDATE_LOGIN = l_terr_all_rec.LAST_UPDATE_LOGIN(i),
      NAME = l_terr_all_rec.NAME(i),
      START_DATE_ACTIVE = l_terr_all_rec.START_DATE_ACTIVE(i),
      END_DATE_ACTIVE = l_terr_all_rec.END_DATE_ACTIVE(i),
      PARENT_TERRITORY_ID = l_terr_all_rec.PARENT_TERRITORY_ID(i),
      TERRITORY_TYPE_ID = l_terr_all_rec.TERRITORY_TYPE_ID(i),
      RANK = l_terr_all_rec.RANK(i),
      DESCRIPTION = l_terr_all_rec.DESCRIPTION(i),
	  ENABLED_FLAG = l_terr_all_rec.ENABLED_FLAG(i),
      ATTRIBUTE_CATEGORY = l_terr_all_rec.ATTRIBUTE_CATEGORY(i),
      ATTRIBUTE1 = l_terr_all_rec.ATTRIBUTE1(i),
      ATTRIBUTE2 = l_terr_all_rec.ATTRIBUTE2(i),
      ATTRIBUTE3 = l_terr_all_rec.ATTRIBUTE3(i),
      ATTRIBUTE4 = l_terr_all_rec.ATTRIBUTE4(i),
      ATTRIBUTE5 = l_terr_all_rec.ATTRIBUTE5(i),
      ATTRIBUTE6 = l_terr_all_rec.ATTRIBUTE6(i),
      ATTRIBUTE7 = l_terr_all_rec.ATTRIBUTE7(i),
      ATTRIBUTE8 = l_terr_all_rec.ATTRIBUTE8(i),
      ATTRIBUTE9 = l_terr_all_rec.ATTRIBUTE9(i),
      ATTRIBUTE10 = l_terr_all_rec.ATTRIBUTE10(i),
      ATTRIBUTE11 = l_terr_all_rec.ATTRIBUTE11(i),
      ATTRIBUTE12 = l_terr_all_rec.ATTRIBUTE12(i),
      ATTRIBUTE13 = l_terr_all_rec.ATTRIBUTE13(i),
      ATTRIBUTE14 = l_terr_all_rec.ATTRIBUTE14(i),
      ATTRIBUTE15 = l_terr_all_rec.ATTRIBUTE15(i),
      ORG_ID      = l_terr_all_rec.ORG_ID(i),
      NUM_WINNERS      = l_terr_all_rec.NUM_WINNERS(i)
    where terr_id = l_terr_all_rec.Terr_Id(i);

	forall i in l_terr_all_rec.lay_seq_num.first..l_terr_all_rec.lay_seq_num.last
		update JTY_WEBADI_OTH_TERR_INTF
		set status = x_return_status
		, error_msg = X_Msg_Data
		where lay_seq_num = l_terr_all_rec.lay_seq_num(i)
		and interface_type = l_intf_type
		and header = l_header
		and user_sequence = p_user_sequence;

  end if;
  EXCEPTION
    WHEN OTHERS THEN
	  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

          fnd_message.clear;
          fnd_message.set_name ('JTF', 'JTY_OTH_TERR_CREATE_TERR');
          X_Msg_Data := fnd_message.get();
          debugmsg (X_Msg_Data || SQLERRM);

  	  update JTY_WEBADI_OTH_TERR_INTF jwot
	  set status = x_return_status,
	  error_msg = X_Msg_Data
	  where jwot.USER_SEQUENCE = p_user_sequence
            and jwot.header = l_header
	    and jwot.interface_type = l_intf_type
            and jwot.action_flag = p_action_flag
            and jwot.status is null;


END UPDATE_TERR;

PROCEDURE UPDATE_TERR_QUAL(
    P_USER_SEQUENCE 		  IN  NUMBER,
--	P_ACTION_FLAG			  IN VARCHAR2,
	x_return_status			  OUT NOCOPY VARCHAR2,
	x_msg_data				  OUT NOCOPY VARCHAR2
) IS

	CURSOR get_qual_csr(
	  v_user_sequence number,
	  v_action_flag	  varchar2,
	  v_intf_type	  varchar2,
	  v_header		  varchar2) IS
    select JTF_TERR_QUAL_s.nextval TERR_QUAL_ID, sub.terr_id, sub.qual_value_id,
  	sub.qual_value1, sub.qual_value2, sub.qual_value3,
  	sub.org_id, sub.last_updated_by, sub.last_update_date,
  	sub.last_update_login, sub.creation_date, sub.created_by,
  	jq.qual_usg_id, jq.display_type qual_type, jq.CONVERT_TO_ID_FLAG,
	jq.qualifier_num, jq.html_lov_sql1,
  	(case
  	  when jq.COMPARISON_OPERATOR = '=' then '='
  	  when (jq.COMPARISON_OPERATOR LIKE '%LIKE%') AND (instr(sub.qual_VALUE1,'_') > 0) or (instr(sub.qual_VALUE1,'%') > 0 and sub.qual_VALUE2 is null) then 'LIKE'
  	  when (jq.COMPARISON_OPERATOR LIKE '%BETWEEN%') AND (sub.qual_VALUE1 is not null and sub.qual_VALUE2 is not null) then 'BETWEEN'
  	  else '='
  	end) qual_cond
      from JTY_WEBADI_QUAL_HEADER jq,
      (
      select terr_id, user_sequence,
      1 qual_num, QUAL1_VALUE_ID qual_value_id,
      QUAL1_VALUE1 qual_VALUE1,
      QUAL1_VALUE2 qual_VALUE2,
      QUAL1_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id1 is null
	  and jut.qual1_value1 is not null
      and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      2 qual_num, QUAL2_VALUE_ID qual_value_id,
      QUAL2_VALUE1 qual_VALUE1,
      QUAL2_VALUE2 qual_VALUE2,
      QUAL2_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id2 is null
	  and jut.qual2_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      3 qual_num, QUAL3_VALUE_ID qual_value_id,
      QUAL3_VALUE1 qual_VALUE1,
      QUAL3_VALUE2 qual_VALUE2,
      QUAL3_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id3 is null
	  and jut.qual3_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      4 qual_num, QUAL4_VALUE_ID qual_value_id,
      QUAL4_VALUE1 qual_VALUE1,
      QUAL4_VALUE2 qual_VALUE2,
      QUAL4_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id4 is null
	  and jut.qual4_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      5 qual_num, QUAL5_VALUE_ID qual_value_id,
      QUAL5_VALUE1 qual_VALUE1,
      QUAL5_VALUE2 qual_VALUE2,
      QUAL5_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id5 is null
	  and jut.qual5_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      6 qual_num, QUAL6_VALUE_ID qual_value_id,
      QUAL6_VALUE1 qual_VALUE1,
      QUAL6_VALUE2 qual_VALUE2,
      QUAL6_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id6 is null
	  and jut.qual6_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      7 qual_num, QUAL7_VALUE_ID qual_value_id,
      QUAL7_VALUE1 qual_VALUE1,
      QUAL7_VALUE2 qual_VALUE2,
      QUAL7_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id7 is null
	  and jut.qual7_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      8 qual_num, QUAL8_VALUE_ID qual_value_id,
      QUAL8_VALUE1 qual_VALUE1,
      QUAL8_VALUE2 qual_VALUE2,
      QUAL8_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id8 is null
	  and jut.qual8_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      9 qual_num, QUAL9_VALUE_ID qual_value_id,
      QUAL9_VALUE1 qual_VALUE1,
      QUAL9_VALUE2 qual_VALUE2,
      QUAL9_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id9 is null
	  and jut.qual9_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      10 qual_num, QUAL10_VALUE_ID qual_value_id,
      QUAL10_VALUE1 qual_VALUE1,
      QUAL10_VALUE2 qual_VALUE2,
      QUAL10_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id10 is null
	  and jut.qual10_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      11 qual_num, QUAL11_VALUE_ID qual_value_id,
      QUAL11_VALUE1 qual_VALUE1,
      QUAL11_VALUE2 qual_VALUE2,
      QUAL11_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id11 is null
	  and jut.qual11_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      12 qual_num, QUAL12_VALUE_ID qual_value_id,
      QUAL12_VALUE1 qual_VALUE1,
      QUAL12_VALUE2 qual_VALUE2,
      QUAL12_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id12 is null
	  and jut.qual12_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      13 qual_num, QUAL13_VALUE_ID qual_value_id,
      QUAL13_VALUE1 qual_VALUE1,
      QUAL13_VALUE2 qual_VALUE2,
      QUAL13_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id13 is null
	  and jut.qual13_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      14 qual_num, QUAL14_VALUE_ID qual_value_id,
      QUAL14_VALUE1 qual_VALUE1,
      QUAL14_VALUE2 qual_VALUE2,
      QUAL14_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id14 is null
	  and jut.qual14_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      15 qual_num, QUAL15_VALUE_ID qual_value_id,
      QUAL15_VALUE1 qual_VALUE1,
      QUAL15_VALUE2 qual_VALUE2,
      QUAL15_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id15 is null
	  and jut.qual15_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      16 qual_num, QUAL16_VALUE_ID qual_value_id,
      QUAL16_VALUE1 qual_VALUE1,
      QUAL16_VALUE2 qual_VALUE2,
      QUAL16_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id16 is null
	  and jut.qual16_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      17 qual_num, QUAL17_VALUE_ID qual_value_id,
      QUAL17_VALUE1 qual_VALUE1,
      QUAL17_VALUE2 qual_VALUE2,
      QUAL17_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id17 is null
	  and jut.qual17_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      18 qual_num, QUAL18_VALUE_ID qual_value_id,
      QUAL18_VALUE1 qual_VALUE1,
      QUAL18_VALUE2 qual_VALUE2,
      QUAL18_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id18 is null
	  and jut.qual18_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      19 qual_num, QUAL19_VALUE_ID qual_value_id,
      QUAL19_VALUE1 qual_VALUE1,
      QUAL19_VALUE2 qual_VALUE2,
      QUAL19_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id19 is null
	  and jut.qual19_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      20 qual_num, QUAL20_VALUE_ID qual_value_id,
      QUAL20_VALUE1 qual_VALUE1,
      QUAL20_VALUE2 qual_VALUE2,
      QUAL20_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id20 is null
	  and jut.qual20_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      21 qual_num, QUAL21_VALUE_ID qual_value_id,
      QUAL21_VALUE1 qual_VALUE1,
      QUAL21_VALUE2 qual_VALUE2,
      QUAL21_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id21 is null
	  and jut.qual21_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      22 qual_num, QUAL22_VALUE_ID qual_value_id,
      QUAL22_VALUE1 qual_VALUE1,
      QUAL22_VALUE2 qual_VALUE2,
      QUAL22_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id22 is null
	  and jut.qual22_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      23 qual_num, QUAL23_VALUE_ID qual_value_id,
      QUAL23_VALUE1 qual_VALUE1,
      QUAL23_VALUE2 qual_VALUE2,
      QUAL23_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id23 is null
	  and jut.qual23_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      24 qual_num, QUAL24_VALUE_ID qual_value_id,
      QUAL24_VALUE1 qual_VALUE1,
      QUAL24_VALUE2 qual_VALUE2,
      QUAL24_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id24 is null
	  and jut.qual24_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      25 qual_num, QUAL25_VALUE_ID qual_value_id,
      QUAL25_VALUE1 qual_valUE1,
      QUAL25_VALUE2 qual_valUE2,
      QUAL25_VALUE3 qual_valUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id25 is null
	  and jut.qual25_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
	  union all
      select terr_id, user_sequence,
      26 qual_num, QUAL26_VALUE_ID qual_value_id,
      QUAL26_VALUE1 qual_VALUE1,
      QUAL26_VALUE2 qual_VALUE2,
      QUAL26_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id26 is null
	  and jut.qual26_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      27 qual_num, QUAL27_VALUE_ID qual_value_id,
      QUAL27_VALUE1 qual_VALUE1,
      QUAL27_VALUE2 qual_VALUE2,
      QUAL27_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id27 is null
	  and jut.qual27_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      28 qual_num, QUAL28_VALUE_ID qual_value_id,
      QUAL28_VALUE1 qual_VALUE1,
      QUAL28_VALUE2 qual_VALUE2,
      QUAL28_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id28 is null
	  and jut.qual28_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      29 qual_num, QUAL29_VALUE_ID qual_value_id,
      QUAL29_VALUE1 qual_VALUE1,
      QUAL29_VALUE2 qual_VALUE2,
      QUAL29_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id29 is null
	  and jut.qual29_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      30 qual_num, QUAL30_VALUE_ID qual_value_id,
      QUAL30_VALUE1 qual_VALUE1,
      QUAL30_VALUE2 qual_VALUE2,
      QUAL30_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id30 is null
	  and jut.QUAL30_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      31 qual_num, QUAL31_VALUE_ID qual_value_id,
      QUAL31_VALUE1 qual_VALUE1,
      QUAL31_VALUE2 qual_VALUE2,
      QUAL31_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id31 is null
	  and jut.QUAL31_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      32 qual_num, QUAL32_VALUE_ID qual_value_id,
      QUAL32_VALUE1 qual_VALUE1,
      QUAL32_VALUE2 qual_VALUE2,
      QUAL32_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id32 is null
	  and jut.QUAL32_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      33 qual_num, QUAL33_VALUE_ID qual_value_id,
      QUAL33_VALUE1 qual_VALUE1,
      QUAL33_VALUE2 qual_VALUE2,
      QUAL33_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id33 is null
	  and jut.QUAL33_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      34 qual_num, QUAL34_VALUE_ID qual_value_id,
      QUAL34_VALUE1 qual_VALUE1,
      QUAL34_VALUE2 qual_VALUE2,
      QUAL34_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id34 is null
	  and jut.QUAL34_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      35 qual_num, QUAL35_VALUE_ID qual_value_id,
      QUAL35_VALUE1 qual_valUE1,
      QUAL35_VALUE2 qual_valUE2,
      QUAL35_VALUE3 qual_valUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id35 is null
	  and jut.QUAL35_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
	  union all
      select terr_id, user_sequence,
      36 qual_num, QUAL36_VALUE_ID qual_value_id,
      QUAL36_VALUE1 qual_VALUE1,
      QUAL36_VALUE2 qual_VALUE2,
      QUAL36_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id36 is null
	  and jut.QUAL36_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      37 qual_num, QUAL37_VALUE_ID qual_value_id,
      QUAL37_VALUE1 qual_VALUE1,
      QUAL37_VALUE2 qual_VALUE2,
      QUAL37_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id37 is null
	  and jut.QUAL37_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      38 qual_num, QUAL38_VALUE_ID qual_value_id,
      QUAL38_VALUE1 qual_VALUE1,
      QUAL38_VALUE2 qual_VALUE2,
      QUAL38_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id38 is null
	  and jut.QUAL38_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      39 qual_num, QUAL39_VALUE_ID qual_value_id,
      QUAL39_VALUE1 qual_VALUE1,
      QUAL39_VALUE2 qual_VALUE2,
      QUAL39_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id39 is null
	  and jut.QUAL39_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      40 qual_num, QUAL40_VALUE_ID qual_value_id,
      QUAL40_VALUE1 qual_VALUE1,
      QUAL40_VALUE2 qual_VALUE2,
      QUAL40_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id40 is null
	  and jut.QUAL40_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      41 qual_num, QUAL41_VALUE_ID qual_value_id,
      QUAL41_VALUE1 qual_VALUE1,
      QUAL41_VALUE2 qual_VALUE2,
      QUAL41_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id41 is null
	  and jut.QUAL41_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      42 qual_num, QUAL42_VALUE_ID qual_value_id,
      QUAL42_VALUE1 qual_VALUE1,
      QUAL42_VALUE2 qual_VALUE2,
      QUAL42_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id42 is null
	  and jut.QUAL42_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      43 qual_num, QUAL43_VALUE_ID qual_value_id,
      QUAL43_VALUE1 qual_VALUE1,
      QUAL43_VALUE2 qual_VALUE2,
      QUAL43_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id43 is null
	  and jut.QUAL43_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      44 qual_num, QUAL44_VALUE_ID qual_value_id,
      QUAL44_VALUE1 qual_VALUE1,
      QUAL44_VALUE2 qual_VALUE2,
      QUAL44_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id44 is null
	  and jut.QUAL44_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      45 qual_num, QUAL45_VALUE_ID qual_value_id,
      QUAL45_VALUE1 qual_valUE1,
      QUAL45_VALUE2 qual_valUE2,
      QUAL45_VALUE3 qual_valUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id45 is null
	  and jut.QUAL45_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
	  union all
      select terr_id, user_sequence,
      46 qual_num, QUAL46_VALUE_ID qual_value_id,
      QUAL46_VALUE1 qual_VALUE1,
      QUAL46_VALUE2 qual_VALUE2,
      QUAL46_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id46 is null
	  and jut.QUAL46_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      47 qual_num, QUAL47_VALUE_ID qual_value_id,
      QUAL47_VALUE1 qual_VALUE1,
      QUAL47_VALUE2 qual_VALUE2,
      QUAL47_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id47 is null
	  and jut.QUAL47_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      48 qual_num, QUAL48_VALUE_ID qual_value_id,
      QUAL48_VALUE1 qual_VALUE1,
      QUAL48_VALUE2 qual_VALUE2,
      QUAL48_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id48 is null
	  and jut.QUAL48_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      49 qual_num, QUAL49_VALUE_ID qual_value_id,
      QUAL49_VALUE1 qual_VALUE1,
      QUAL49_VALUE2 qual_VALUE2,
      QUAL49_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id49 is null
	  and jut.QUAL49_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      50 qual_num, QUAL50_VALUE_ID qual_value_id,
      QUAL50_VALUE1 qual_VALUE1,
      QUAL50_VALUE2 qual_VALUE2,
      QUAL50_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id50 is null
	  and jut.QUAL50_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      51 qual_num, QUAL51_VALUE_ID qual_value_id,
      QUAL51_VALUE1 qual_VALUE1,
      QUAL51_VALUE2 qual_VALUE2,
      QUAL51_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id51 is null
	  and jut.QUAL51_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      52 qual_num, QUAL52_VALUE_ID qual_value_id,
      QUAL52_VALUE1 qual_VALUE1,
      QUAL52_VALUE2 qual_VALUE2,
      QUAL52_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id52 is null
	  and jut.QUAL52_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      53 qual_num, QUAL53_VALUE_ID qual_value_id,
      QUAL53_VALUE1 qual_VALUE1,
      QUAL53_VALUE2 qual_VALUE2,
      QUAL53_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id53 is null
	  and jut.QUAL53_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      54 qual_num, QUAL54_VALUE_ID qual_value_id,
      QUAL54_VALUE1 qual_VALUE1,
      QUAL54_VALUE2 qual_VALUE2,
      QUAL54_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id54 is null
	  and jut.QUAL54_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      55 qual_num, QUAL55_VALUE_ID qual_value_id,
      QUAL55_VALUE1 qual_valUE1,
      QUAL55_VALUE2 qual_valUE2,
      QUAL55_VALUE3 qual_valUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id55 is null
	  and jut.QUAL55_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
	  union all
      select terr_id, user_sequence,
      56 qual_num, QUAL56_VALUE_ID qual_value_id,
      QUAL56_VALUE1 qual_VALUE1,
      QUAL56_VALUE2 qual_VALUE2,
      QUAL56_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id56 is null
	  and jut.QUAL56_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      57 qual_num, QUAL57_VALUE_ID qual_value_id,
      QUAL57_VALUE1 qual_VALUE1,
      QUAL57_VALUE2 qual_VALUE2,
      QUAL57_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id57 is null
	  and jut.QUAL57_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      58 qual_num, QUAL58_VALUE_ID qual_value_id,
      QUAL58_VALUE1 qual_VALUE1,
      QUAL58_VALUE2 qual_VALUE2,
      QUAL58_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id58 is null
	  and jut.QUAL58_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      59 qual_num, QUAL59_VALUE_ID qual_value_id,
      QUAL59_VALUE1 qual_VALUE1,
      QUAL59_VALUE2 qual_VALUE2,
      QUAL59_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id59 is null
	  and jut.QUAL59_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      60 qual_num, QUAL60_VALUE_ID qual_value_id,
      QUAL60_VALUE1 qual_VALUE1,
      QUAL60_VALUE2 qual_VALUE2,
      QUAL60_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id60 is null
	  and jut.QUAL60_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      61 qual_num, QUAL61_VALUE_ID qual_value_id,
      QUAL61_VALUE1 qual_VALUE1,
      QUAL61_VALUE2 qual_VALUE2,
      QUAL61_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id61 is null
	  and jut.QUAL61_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      62 qual_num, QUAL62_VALUE_ID qual_value_id,
      QUAL62_VALUE1 qual_VALUE1,
      QUAL62_VALUE2 qual_VALUE2,
      QUAL62_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id62 is null
	  and jut.QUAL62_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      63 qual_num, QUAL63_VALUE_ID qual_value_id,
      QUAL63_VALUE1 qual_VALUE1,
      QUAL63_VALUE2 qual_VALUE2,
      QUAL63_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id63 is null
	  and jut.QUAL63_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      64 qual_num, QUAL64_VALUE_ID qual_value_id,
      QUAL64_VALUE1 qual_VALUE1,
      QUAL64_VALUE2 qual_VALUE2,
      QUAL64_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id64 is null
	  and jut.QUAL64_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      65 qual_num, QUAL65_VALUE_ID qual_value_id,
      QUAL65_VALUE1 qual_valUE1,
      QUAL65_VALUE2 qual_valUE2,
      QUAL65_VALUE3 qual_valUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id65 is null
	  and jut.QUAL65_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
	  union all
      select terr_id, user_sequence,
      66 qual_num, QUAL66_VALUE_ID qual_value_id,
      QUAL66_VALUE1 qual_VALUE1,
      QUAL66_VALUE2 qual_VALUE2,
      QUAL66_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id66 is null
	  and jut.QUAL66_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      67 qual_num, QUAL67_VALUE_ID qual_value_id,
      QUAL67_VALUE1 qual_VALUE1,
      QUAL67_VALUE2 qual_VALUE2,
      QUAL67_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id67 is null
	  and jut.QUAL67_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      68 qual_num, QUAL68_VALUE_ID qual_value_id,
      QUAL68_VALUE1 qual_VALUE1,
      QUAL68_VALUE2 qual_VALUE2,
      QUAL68_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id68 is null
	  and jut.QUAL68_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      69 qual_num, QUAL69_VALUE_ID qual_value_id,
      QUAL69_VALUE1 qual_VALUE1,
      QUAL69_VALUE2 qual_VALUE2,
      QUAL69_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id69 is null
	  and jut.QUAL69_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      70 qual_num, QUAL70_VALUE_ID qual_value_id,
      QUAL70_VALUE1 qual_VALUE1,
      QUAL70_VALUE2 qual_VALUE2,
      QUAL70_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id70 is null
	  and jut.QUAL70_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      71 qual_num, QUAL71_VALUE_ID qual_value_id,
      QUAL71_VALUE1 qual_VALUE1,
      QUAL71_VALUE2 qual_VALUE2,
      QUAL71_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id71 is null
	  and jut.QUAL71_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      72 qual_num, QUAL72_VALUE_ID qual_value_id,
      QUAL72_VALUE1 qual_VALUE1,
      QUAL72_VALUE2 qual_VALUE2,
      QUAL72_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id72 is null
	  and jut.QUAL72_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      73 qual_num, QUAL73_VALUE_ID qual_value_id,
      QUAL73_VALUE1 qual_VALUE1,
      QUAL73_VALUE2 qual_VALUE2,
      QUAL73_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id73 is null
	  and jut.QUAL73_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      74 qual_num, QUAL74_VALUE_ID qual_value_id,
      QUAL74_VALUE1 qual_VALUE1,
      QUAL74_VALUE2 qual_VALUE2,
      QUAL74_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id74 is null
	  and jut.QUAL74_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
      75 qual_num, QUAL75_VALUE_ID qual_value_id,
      QUAL75_VALUE1 qual_valUE1,
      QUAL75_VALUE2 qual_valUE2,
      QUAL75_VALUE3 qual_valUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id75 is null
	  and jut.QUAL75_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
) sub
      where jq.user_sequence = sub.user_sequence
        and jq.qualifier_num = sub.qual_num
		;

	CURSOR get_c_terr_value_csr(
	  v_user_sequence number,
	  v_intf_type	  varchar2,
	  v_header		  varchar2) IS
    select sub.TERR_QUAL_ID, sub.terr_id, sub.qual_value_id,
  	sub.qual_value1, sub.qual_value2, sub.qual_value3,
  	sub.org_id, sub.last_updated_by, sub.last_update_date,
  	sub.last_update_login, sub.creation_date, sub.created_by,
  	jq.qual_usg_id, jq.display_type qual_type, jq.CONVERT_TO_ID_FLAG,
	jq.qualifier_num, jq.html_lov_sql1,
  	(case
  	  when jq.COMPARISON_OPERATOR = '=' then '='
  	  when (jq.COMPARISON_OPERATOR LIKE '%LIKE%') AND (instr(sub.qual_VALUE1,'_') > 0) or (instr(sub.qual_VALUE1,'%') > 0 and sub.qual_VALUE2 is null) then 'LIKE'
  	  when (jq.COMPARISON_OPERATOR LIKE '%BETWEEN%') AND (sub.qual_VALUE1 is not null and sub.qual_VALUE2 is not null) then 'BETWEEN'
  	  else '='
  	end) qual_cond
      from JTY_WEBADI_QUAL_HEADER jq,
      (
      select terr_id, user_sequence,
	  terr_qual_id1 terr_qual_id,
      1 qual_num, QUAL1_VALUE_ID qual_value_id,
      QUAL1_VALUE1 qual_VALUE1,
      QUAL1_VALUE2 qual_VALUE2,
      QUAL1_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id1 is not null
	  and jut.QUAL1_VALUE_ID is null
	  and jut.qual1_value1 is not null
      and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id2 terr_qual_id,
      2 qual_num, QUAL2_VALUE_ID qual_value_id,
      QUAL2_VALUE1 qual_VALUE1,
      QUAL2_VALUE2 qual_VALUE2,
      QUAL2_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id2 is not null
	  and jut.QUAL2_VALUE_ID is null
	  and jut.qual2_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id3 terr_qual_id,
      3 qual_num, QUAL3_VALUE_ID qual_value_id,
      QUAL3_VALUE1 qual_VALUE1,
      QUAL3_VALUE2 qual_VALUE2,
      QUAL3_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id3 is not null
	  and jut.QUAL3_VALUE_ID is null
	  and jut.qual3_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id4 terr_qual_id,
      4 qual_num, QUAL4_VALUE_ID qual_value_id,
      QUAL4_VALUE1 qual_VALUE1,
      QUAL4_VALUE2 qual_VALUE2,
      QUAL4_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id4 is not null
	  and jut.QUAL4_VALUE_ID is null
	  and jut.qual4_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id5 terr_qual_id,
      5 qual_num, QUAL5_VALUE_ID qual_value_id,
      QUAL5_VALUE1 qual_VALUE1,
      QUAL5_VALUE2 qual_VALUE2,
      QUAL5_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id5 is not null
	  and jut.QUAL5_VALUE_ID is null
	  and jut.qual5_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id6 terr_qual_id,
      6 qual_num, QUAL6_VALUE_ID qual_value_id,
      QUAL6_VALUE1 qual_VALUE1,
      QUAL6_VALUE2 qual_VALUE2,
      QUAL6_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id6 is not null
	  and jut.QUAL6_VALUE_ID is null
	  and jut.qual6_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id7 terr_qual_id,
      7 qual_num, QUAL7_VALUE_ID qual_value_id,
      QUAL7_VALUE1 qual_VALUE1,
      QUAL7_VALUE2 qual_VALUE2,
      QUAL7_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id7 is not null
	  and jut.QUAL7_VALUE_ID is null
	  and jut.qual7_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id8 terr_qual_id,
      8 qual_num, QUAL8_VALUE_ID qual_value_id,
      QUAL8_VALUE1 qual_VALUE1,
      QUAL8_VALUE2 qual_VALUE2,
      QUAL8_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id8 is not null
	  and jut.QUAL8_VALUE_ID is null
	  and jut.qual8_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id9 terr_qual_id,
      9 qual_num, QUAL9_VALUE_ID qual_value_id,
      QUAL9_VALUE1 qual_VALUE1,
      QUAL9_VALUE2 qual_VALUE2,
      QUAL9_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id9 is not null
	  and jut.QUAL9_VALUE_ID is null
	  and jut.qual9_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id10 terr_qual_id,
      10 qual_num, QUAL10_VALUE_ID qual_value_id,
      QUAL10_VALUE1 qual_VALUE1,
      QUAL10_VALUE2 qual_VALUE2,
      QUAL10_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id10 is not null
	  and jut.QUAL10_VALUE_ID is null
	  and jut.qual10_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id11 terr_qual_id,
      11 qual_num, QUAL11_VALUE_ID qual_value_id,
      QUAL11_VALUE1 qual_VALUE1,
      QUAL11_VALUE2 qual_VALUE2,
      QUAL11_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id11 is not null
	  and jut.QUAL11_VALUE_ID is null
	  and jut.qual11_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id12 terr_qual_id,
      12 qual_num, QUAL12_VALUE_ID qual_value_id,
      QUAL12_VALUE1 qual_VALUE1,
      QUAL12_VALUE2 qual_VALUE2,
      QUAL12_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id12 is not null
	  and jut.QUAL12_VALUE_ID is null
	  and jut.qual12_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id13 terr_qual_id,
      13 qual_num, QUAL13_VALUE_ID qual_value_id,
      QUAL13_VALUE1 qual_VALUE1,
      QUAL13_VALUE2 qual_VALUE2,
      QUAL13_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id13 is not null
	  and jut.QUAL13_VALUE_ID is null
	  and jut.qual13_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id14 terr_qual_id,
      14 qual_num, QUAL14_VALUE_ID qual_value_id,
      QUAL14_VALUE1 qual_VALUE1,
      QUAL14_VALUE2 qual_VALUE2,
      QUAL14_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id14 is not null
	  and jut.QUAL14_VALUE_ID is null
	  and jut.qual14_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id15 terr_qual_id,
      15 qual_num, QUAL15_VALUE_ID qual_value_id,
      QUAL15_VALUE1 qual_VALUE1,
      QUAL15_VALUE2 qual_VALUE2,
      QUAL15_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id15 is not null
	  and jut.QUAL15_VALUE_ID is null
	  and jut.qual15_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id16 terr_qual_id,
      16 qual_num, QUAL16_VALUE_ID qual_value_id,
      QUAL16_VALUE1 qual_VALUE1,
      QUAL16_VALUE2 qual_VALUE2,
      QUAL16_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id16 is not null
	  and jut.QUAL16_VALUE_ID is null
	  and jut.qual16_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id17 terr_qual_id,
      17 qual_num, QUAL17_VALUE_ID qual_value_id,
      QUAL17_VALUE1 qual_VALUE1,
      QUAL17_VALUE2 qual_VALUE2,
      QUAL17_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id17 is not null
	  and jut.QUAL17_VALUE_ID is null
	  and jut.qual17_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id18 terr_qual_id,
      18 qual_num, QUAL18_VALUE_ID qual_value_id,
      QUAL18_VALUE1 qual_VALUE1,
      QUAL18_VALUE2 qual_VALUE2,
      QUAL18_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id18 is not null
	  and jut.QUAL18_VALUE_ID is null
	  and jut.qual18_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id19 terr_qual_id,
      19 qual_num, QUAL19_VALUE_ID qual_value_id,
      QUAL19_VALUE1 qual_VALUE1,
      QUAL19_VALUE2 qual_VALUE2,
      QUAL19_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id19 is not null
	  and jut.QUAL19_VALUE_ID is null
	  and jut.qual19_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id20 terr_qual_id,
      20 qual_num, QUAL20_VALUE_ID qual_value_id,
      QUAL20_VALUE1 qual_VALUE1,
      QUAL20_VALUE2 qual_VALUE2,
      QUAL20_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id20 is not null
	  and jut.QUAL20_VALUE_ID is null
	  and jut.qual20_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id21 terr_qual_id,
      21 qual_num, QUAL21_VALUE_ID qual_value_id,
      QUAL21_VALUE1 qual_VALUE1,
      QUAL21_VALUE2 qual_VALUE2,
      QUAL21_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id21 is not null
	  and jut.QUAL21_VALUE_ID is null
	  and jut.qual21_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id22 terr_qual_id,
      22 qual_num, QUAL22_VALUE_ID qual_value_id,
      QUAL22_VALUE1 qual_VALUE1,
      QUAL22_VALUE2 qual_VALUE2,
      QUAL22_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id22 is not null
	  and jut.QUAL22_VALUE_ID is null
	  and jut.qual22_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id23 terr_qual_id,
      23 qual_num, QUAL23_VALUE_ID qual_value_id,
      QUAL23_VALUE1 qual_VALUE1,
      QUAL23_VALUE2 qual_VALUE2,
      QUAL23_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id23 is not null
	  and jut.QUAL23_VALUE_ID is null
	  and jut.qual23_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id24 terr_qual_id,
      24 qual_num, QUAL24_VALUE_ID qual_value_id,
      QUAL24_VALUE1 qual_VALUE1,
      QUAL24_VALUE2 qual_VALUE2,
      QUAL24_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id24 is not null
	  and jut.QUAL24_VALUE_ID is null
	  and jut.qual24_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id25 terr_qual_id,
      25 qual_num, QUAL25_VALUE_ID qual_value_id,
      QUAL25_VALUE1 qual_valUE1,
      QUAL25_VALUE2 qual_valUE2,
      QUAL25_VALUE3 qual_valUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id25 is not null
	  and jut.QUAL25_VALUE_ID is null
	  and jut.qual25_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
	  union all
      select terr_id, user_sequence,
	  terr_qual_id26 terr_qual_id,
      26 qual_num, QUAL26_VALUE_ID qual_value_id,
      QUAL26_VALUE1 qual_VALUE1,
      QUAL26_VALUE2 qual_VALUE2,
      QUAL26_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id26 is not null
	  and jut.QUAL26_VALUE_ID is null
	  and jut.QUAL26_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id27 terr_qual_id,
      27 qual_num, QUAL27_VALUE_ID qual_value_id,
      QUAL27_VALUE1 qual_VALUE1,
      QUAL27_VALUE2 qual_VALUE2,
      QUAL27_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id27 is not null
	  and jut.QUAL27_VALUE_ID is null
	  and jut.QUAL27_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id28 terr_qual_id,
      28 qual_num, QUAL28_VALUE_ID qual_value_id,
      QUAL28_VALUE1 qual_VALUE1,
      QUAL28_VALUE2 qual_VALUE2,
      QUAL28_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id28 is not null
	  and jut.QUAL28_VALUE_ID is null
	  and jut.QUAL28_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id29 terr_qual_id,
      29 qual_num, QUAL29_VALUE_ID qual_value_id,
      QUAL29_VALUE1 qual_VALUE1,
      QUAL29_VALUE2 qual_VALUE2,
      QUAL29_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id29 is not null
	  and jut.QUAL29_VALUE_ID is null
	  and jut.QUAL29_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id30 terr_qual_id,
      30 qual_num, QUAL30_VALUE_ID qual_value_id,
      QUAL30_VALUE1 qual_VALUE1,
      QUAL30_VALUE2 qual_VALUE2,
      QUAL30_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id30 is not null
	  and jut.QUAL30_VALUE_ID is null
	  and jut.QUAL30_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id31 terr_qual_id,
      31 qual_num, QUAL31_VALUE_ID qual_value_id,
      QUAL31_VALUE1 qual_VALUE1,
      QUAL31_VALUE2 qual_VALUE2,
      QUAL31_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id31 is not null
	  and jut.QUAL31_VALUE_ID is null
	  and jut.QUAL31_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id32 terr_qual_id,
      32 qual_num, QUAL32_VALUE_ID qual_value_id,
      QUAL32_VALUE1 qual_VALUE1,
      QUAL32_VALUE2 qual_VALUE2,
      QUAL32_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id32 is not null
	  and jut.QUAL32_VALUE_ID is null
	  and jut.QUAL32_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id33 terr_qual_id,
      33 qual_num, QUAL33_VALUE_ID qual_value_id,
      QUAL33_VALUE1 qual_VALUE1,
      QUAL33_VALUE2 qual_VALUE2,
      QUAL33_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id33 is not null
	  and jut.QUAL33_VALUE_ID is null
	  and jut.QUAL33_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id34 terr_qual_id,
      34 qual_num, QUAL34_VALUE_ID qual_value_id,
      QUAL34_VALUE1 qual_VALUE1,
      QUAL34_VALUE2 qual_VALUE2,
      QUAL34_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id34 is not null
	  and jut.QUAL34_VALUE_ID is null
	  and jut.QUAL34_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id35 terr_qual_id,
      35 qual_num, QUAL35_VALUE_ID qual_value_id,
      QUAL35_VALUE1 qual_valUE1,
      QUAL35_VALUE2 qual_valUE2,
      QUAL35_VALUE3 qual_valUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id35 is not null
	  and jut.QUAL35_VALUE_ID is null
	  and jut.QUAL35_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
	  union all
      select terr_id, user_sequence,
	  terr_qual_id36 terr_qual_id,
      36 qual_num, QUAL36_VALUE_ID qual_value_id,
      QUAL36_VALUE1 qual_VALUE1,
      QUAL36_VALUE2 qual_VALUE2,
      QUAL36_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id36 is not null
	  and jut.QUAL36_VALUE_ID is null
	  and jut.QUAL36_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id37 terr_qual_id,
      37 qual_num, QUAL37_VALUE_ID qual_value_id,
      QUAL37_VALUE1 qual_VALUE1,
      QUAL37_VALUE2 qual_VALUE2,
      QUAL37_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id37 is not null
	  and jut.QUAL37_VALUE_ID is null
	  and jut.QUAL37_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id38 terr_qual_id,
      38 qual_num, QUAL38_VALUE_ID qual_value_id,
      QUAL38_VALUE1 qual_VALUE1,
      QUAL38_VALUE2 qual_VALUE2,
      QUAL38_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id38 is not null
	  and jut.QUAL38_VALUE_ID is null
	  and jut.QUAL38_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id39 terr_qual_id,
      39 qual_num, QUAL39_VALUE_ID qual_value_id,
      QUAL39_VALUE1 qual_VALUE1,
      QUAL39_VALUE2 qual_VALUE2,
      QUAL39_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id39 is not null
	  and jut.QUAL39_VALUE_ID is null
	  and jut.QUAL39_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id40 terr_qual_id,
      40 qual_num, QUAL40_VALUE_ID qual_value_id,
      QUAL40_VALUE1 qual_VALUE1,
      QUAL40_VALUE2 qual_VALUE2,
      QUAL40_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id40 is not null
	  and jut.QUAL40_VALUE_ID is null
	  and jut.QUAL40_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id41 terr_qual_id,
      41 qual_num, QUAL41_VALUE_ID qual_value_id,
      QUAL41_VALUE1 qual_VALUE1,
      QUAL41_VALUE2 qual_VALUE2,
      QUAL41_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id41 is not null
	  and jut.QUAL41_VALUE_ID is null
	  and jut.QUAL41_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id42 terr_qual_id,
      42 qual_num, QUAL42_VALUE_ID qual_value_id,
      QUAL42_VALUE1 qual_VALUE1,
      QUAL42_VALUE2 qual_VALUE2,
      QUAL42_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id42 is not null
	  and jut.QUAL42_VALUE_ID is null
	  and jut.QUAL42_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id43 terr_qual_id,
      43 qual_num, QUAL43_VALUE_ID qual_value_id,
      QUAL43_VALUE1 qual_VALUE1,
      QUAL43_VALUE2 qual_VALUE2,
      QUAL43_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id43 is not null
	  and jut.QUAL43_VALUE_ID is null
	  and jut.QUAL43_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id44 terr_qual_id,
      44 qual_num, QUAL44_VALUE_ID qual_value_id,
      QUAL44_VALUE1 qual_VALUE1,
      QUAL44_VALUE2 qual_VALUE2,
      QUAL44_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id44 is not null
	  and jut.QUAL44_VALUE_ID is null
	  and jut.QUAL44_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id45 terr_qual_id,
      45 qual_num, QUAL45_VALUE_ID qual_value_id,
      QUAL45_VALUE1 qual_valUE1,
      QUAL45_VALUE2 qual_valUE2,
      QUAL45_VALUE3 qual_valUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id45 is not null
	  and jut.QUAL45_VALUE_ID is null
	  and jut.QUAL45_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
	  union all
      select terr_id, user_sequence,
	  terr_qual_id46 terr_qual_id,
      46 qual_num, QUAL46_VALUE_ID qual_value_id,
      QUAL46_VALUE1 qual_VALUE1,
      QUAL46_VALUE2 qual_VALUE2,
      QUAL46_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id46 is not null
	  and jut.QUAL46_VALUE_ID is null
	  and jut.QUAL46_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id47 terr_qual_id,
      47 qual_num, QUAL47_VALUE_ID qual_value_id,
      QUAL47_VALUE1 qual_VALUE1,
      QUAL47_VALUE2 qual_VALUE2,
      QUAL47_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id47 is not null
	  and jut.QUAL47_VALUE_ID is null
	  and jut.QUAL47_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id48 terr_qual_id,
      48 qual_num, QUAL48_VALUE_ID qual_value_id,
      QUAL48_VALUE1 qual_VALUE1,
      QUAL48_VALUE2 qual_VALUE2,
      QUAL48_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id48 is not null
	  and jut.QUAL48_VALUE_ID is null
	  and jut.QUAL48_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id49 terr_qual_id,
      49 qual_num, QUAL49_VALUE_ID qual_value_id,
      QUAL49_VALUE1 qual_VALUE1,
      QUAL49_VALUE2 qual_VALUE2,
      QUAL49_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id49 is not null
	  and jut.QUAL49_VALUE_ID is null
	  and jut.QUAL49_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id50 terr_qual_id,
      50 qual_num, QUAL50_VALUE_ID qual_value_id,
      QUAL50_VALUE1 qual_VALUE1,
      QUAL50_VALUE2 qual_VALUE2,
      QUAL50_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id50 is not null
	  and jut.QUAL50_VALUE_ID is null
	  and jut.QUAL50_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id51 terr_qual_id,
      51 qual_num, QUAL51_VALUE_ID qual_value_id,
      QUAL51_VALUE1 qual_VALUE1,
      QUAL51_VALUE2 qual_VALUE2,
      QUAL51_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id51 is not null
	  and jut.QUAL51_VALUE_ID is null
	  and jut.QUAL51_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id52 terr_qual_id,
      52 qual_num, QUAL52_VALUE_ID qual_value_id,
      QUAL52_VALUE1 qual_VALUE1,
      QUAL52_VALUE2 qual_VALUE2,
      QUAL52_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id52 is not null
	  and jut.QUAL52_VALUE_ID is null
	  and jut.QUAL52_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id53 terr_qual_id,
      53 qual_num, QUAL53_VALUE_ID qual_value_id,
      QUAL53_VALUE1 qual_VALUE1,
      QUAL53_VALUE2 qual_VALUE2,
      QUAL53_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id53 is not null
	  and jut.QUAL53_VALUE_ID is null
	  and jut.QUAL53_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id54 terr_qual_id,
      54 qual_num, QUAL54_VALUE_ID qual_value_id,
      QUAL54_VALUE1 qual_VALUE1,
      QUAL54_VALUE2 qual_VALUE2,
      QUAL54_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id54 is not null
	  and jut.QUAL54_VALUE_ID is null
	  and jut.QUAL54_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id55 terr_qual_id,
      55 qual_num, QUAL55_VALUE_ID qual_value_id,
      QUAL55_VALUE1 qual_valUE1,
      QUAL55_VALUE2 qual_valUE2,
      QUAL55_VALUE3 qual_valUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id55 is not null
	  and jut.QUAL55_VALUE_ID is null
	  and jut.QUAL55_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
	  union all
      select terr_id, user_sequence,
	  terr_qual_id56 terr_qual_id,
      56 qual_num, QUAL56_VALUE_ID qual_value_id,
      QUAL56_VALUE1 qual_VALUE1,
      QUAL56_VALUE2 qual_VALUE2,
      QUAL56_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id56 is not null
	  and jut.QUAL56_VALUE_ID is null
	  and jut.QUAL56_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id57 terr_qual_id,
      57 qual_num, QUAL57_VALUE_ID qual_value_id,
      QUAL57_VALUE1 qual_VALUE1,
      QUAL57_VALUE2 qual_VALUE2,
      QUAL57_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id57 is not null
	  and jut.QUAL57_VALUE_ID is null
	  and jut.QUAL57_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id58 terr_qual_id,
      58 qual_num, QUAL58_VALUE_ID qual_value_id,
      QUAL58_VALUE1 qual_VALUE1,
      QUAL58_VALUE2 qual_VALUE2,
      QUAL58_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id58 is not null
	  and jut.QUAL58_VALUE_ID is null
	  and jut.QUAL58_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id59 terr_qual_id,
      59 qual_num, QUAL59_VALUE_ID qual_value_id,
      QUAL59_VALUE1 qual_VALUE1,
      QUAL59_VALUE2 qual_VALUE2,
      QUAL59_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id59 is not null
	  and jut.QUAL59_VALUE_ID is null
	  and jut.QUAL59_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id60 terr_qual_id,
      60 qual_num, QUAL60_VALUE_ID qual_value_id,
      QUAL60_VALUE1 qual_VALUE1,
      QUAL60_VALUE2 qual_VALUE2,
      QUAL60_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id60 is not null
	  and jut.QUAL60_VALUE_ID is null
	  and jut.QUAL60_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id61 terr_qual_id,
      61 qual_num, QUAL61_VALUE_ID qual_value_id,
      QUAL61_VALUE1 qual_VALUE1,
      QUAL61_VALUE2 qual_VALUE2,
      QUAL61_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id61 is not null
	  and jut.QUAL61_VALUE_ID is null
	  and jut.QUAL61_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id62 terr_qual_id,
      62 qual_num, QUAL62_VALUE_ID qual_value_id,
      QUAL62_VALUE1 qual_VALUE1,
      QUAL62_VALUE2 qual_VALUE2,
      QUAL62_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id62 is not null
	  and jut.QUAL62_VALUE_ID is null
	  and jut.QUAL62_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id63 terr_qual_id,
      63 qual_num, QUAL63_VALUE_ID qual_value_id,
      QUAL63_VALUE1 qual_VALUE1,
      QUAL63_VALUE2 qual_VALUE2,
      QUAL63_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id63 is not null
	  and jut.QUAL63_VALUE_ID is null
	  and jut.QUAL63_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id64 terr_qual_id,
      64 qual_num, QUAL64_VALUE_ID qual_value_id,
      QUAL64_VALUE1 qual_VALUE1,
      QUAL64_VALUE2 qual_VALUE2,
      QUAL64_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id64 is not null
	  and jut.QUAL64_VALUE_ID is null
	  and jut.QUAL64_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id65 terr_qual_id,
      65 qual_num, QUAL65_VALUE_ID qual_value_id,
      QUAL65_VALUE1 qual_valUE1,
      QUAL65_VALUE2 qual_valUE2,
      QUAL65_VALUE3 qual_valUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id65 is not null
	  and jut.QUAL65_VALUE_ID is null
	  and jut.QUAL65_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
	  union all
      select terr_id, user_sequence,
	  terr_qual_id66 terr_qual_id,
      66 qual_num, QUAL66_VALUE_ID qual_value_id,
      QUAL66_VALUE1 qual_VALUE1,
      QUAL66_VALUE2 qual_VALUE2,
      QUAL66_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id66 is not null
	  and jut.QUAL66_VALUE_ID is null
	  and jut.QUAL66_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id67 terr_qual_id,
      67 qual_num, QUAL67_VALUE_ID qual_value_id,
      QUAL67_VALUE1 qual_VALUE1,
      QUAL67_VALUE2 qual_VALUE2,
      QUAL67_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id67 is not null
	  and jut.QUAL67_VALUE_ID is null
	  and jut.QUAL67_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id68 terr_qual_id,
      68 qual_num, QUAL68_VALUE_ID qual_value_id,
      QUAL68_VALUE1 qual_VALUE1,
      QUAL68_VALUE2 qual_VALUE2,
      QUAL68_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id68 is not null
	  and jut.QUAL68_VALUE_ID is null
	  and jut.QUAL68_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id69 terr_qual_id,
      69 qual_num, QUAL69_VALUE_ID qual_value_id,
      QUAL69_VALUE1 qual_VALUE1,
      QUAL69_VALUE2 qual_VALUE2,
      QUAL69_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id69 is not null
	  and jut.QUAL69_VALUE_ID is null
	  and jut.QUAL69_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id70 terr_qual_id,
      70 qual_num, QUAL70_VALUE_ID qual_value_id,
      QUAL70_VALUE1 qual_VALUE1,
      QUAL70_VALUE2 qual_VALUE2,
      QUAL70_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id70 is not null
	  and jut.QUAL70_VALUE_ID is null
	  and jut.QUAL70_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id71 terr_qual_id,
      71 qual_num, QUAL71_VALUE_ID qual_value_id,
      QUAL71_VALUE1 qual_VALUE1,
      QUAL71_VALUE2 qual_VALUE2,
      QUAL71_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id71 is not null
	  and jut.QUAL71_VALUE_ID is null
	  and jut.QUAL71_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id72 terr_qual_id,
      72 qual_num, QUAL72_VALUE_ID qual_value_id,
      QUAL72_VALUE1 qual_VALUE1,
      QUAL72_VALUE2 qual_VALUE2,
      QUAL72_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id72 is not null
	  and jut.QUAL72_VALUE_ID is null
	  and jut.QUAL72_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id73 terr_qual_id,
      73 qual_num, QUAL73_VALUE_ID qual_value_id,
      QUAL73_VALUE1 qual_VALUE1,
      QUAL73_VALUE2 qual_VALUE2,
      QUAL73_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id73 is not null
	  and jut.QUAL73_VALUE_ID is null
	  and jut.QUAL73_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id74 terr_qual_id,
      74 qual_num, QUAL74_VALUE_ID qual_value_id,
      QUAL74_VALUE1 qual_VALUE1,
      QUAL74_VALUE2 qual_VALUE2,
      QUAL74_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id74 is not null
	  and jut.QUAL74_VALUE_ID is null
	  and jut.QUAL74_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id75 terr_qual_id,
      75 qual_num, QUAL75_VALUE_ID qual_value_id,
      QUAL75_VALUE1 qual_valUE1,
      QUAL75_VALUE2 qual_valUE2,
      QUAL75_VALUE3 qual_valUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id75 is not null
	  and jut.QUAL75_VALUE_ID is null
	  and jut.QUAL75_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
  	  and jut.header = v_header
	  ) sub
      where jq.user_sequence = sub.user_sequence
        and jq.qualifier_num = sub.qual_num;

	CURSOR get_u_terr_value_csr(
	  v_user_sequence number,
	  v_action_flag	  varchar2,
	  v_intf_type	  varchar2,
	  v_header		  varchar2) IS
    select sub.TERR_QUAL_ID, sub.terr_id, sub.qual_value_id,
  	sub.qual_value1, sub.qual_value2, sub.qual_value3,
  	sub.org_id, sub.last_updated_by, sub.last_update_date,
  	sub.last_update_login, sub.creation_date, sub.created_by,
  	jq.qual_usg_id, jq.display_type qual_type, jq.CONVERT_TO_ID_FLAG,
	jq.qualifier_num, jq.html_lov_sql1,
  	(case
  	  when jq.COMPARISON_OPERATOR = '=' then '='
  	  when (jq.COMPARISON_OPERATOR LIKE '%LIKE%') AND (instr(sub.qual_VALUE1,'_') > 0) or (instr(sub.qual_VALUE1,'%') > 0 and sub.qual_VALUE2 is null) then 'LIKE'
  	  when (jq.COMPARISON_OPERATOR LIKE '%BETWEEN%') AND (sub.qual_VALUE1 is not null and sub.qual_VALUE2 is not null) then 'BETWEEN'
  	  else '='
  	end) qual_cond
      from JTY_WEBADI_QUAL_HEADER jq,
      (
      select terr_id, user_sequence,
	  terr_qual_id1 terr_qual_id,
      1 qual_num, QUAL1_VALUE_ID qual_value_id,
      QUAL1_VALUE1 qual_VALUE1,
      QUAL1_VALUE2 qual_VALUE2,
      QUAL1_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id1 is not null
	  and jut.QUAL1_VALUE_ID is not null
	  and jut.qual1_value1 is not null
      and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id2 terr_qual_id,
      2 qual_num, QUAL2_VALUE_ID qual_value_id,
      QUAL2_VALUE1 qual_VALUE1,
      QUAL2_VALUE2 qual_VALUE2,
      QUAL2_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id2 is not null
	  and jut.QUAL2_VALUE_ID is not null
	  and jut.qual2_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id3 terr_qual_id,
      3 qual_num, QUAL3_VALUE_ID qual_value_id,
      QUAL3_VALUE1 qual_VALUE1,
      QUAL3_VALUE2 qual_VALUE2,
      QUAL3_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id3 is not null
	  and jut.QUAL3_VALUE_ID is not null
	  and jut.qual3_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id4 terr_qual_id,
      4 qual_num, QUAL4_VALUE_ID qual_value_id,
      QUAL4_VALUE1 qual_VALUE1,
      QUAL4_VALUE2 qual_VALUE2,
      QUAL4_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id4 is not null
	  and jut.QUAL4_VALUE_ID is not null
	  and jut.qual4_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id5 terr_qual_id,
      5 qual_num, QUAL5_VALUE_ID qual_value_id,
      QUAL5_VALUE1 qual_VALUE1,
      QUAL5_VALUE2 qual_VALUE2,
      QUAL5_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id5 is not null
	  and jut.QUAL5_VALUE_ID is not null
	  and jut.qual5_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id6 terr_qual_id,
      6 qual_num, QUAL6_VALUE_ID qual_value_id,
      QUAL6_VALUE1 qual_VALUE1,
      QUAL6_VALUE2 qual_VALUE2,
      QUAL6_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id6 is not null
	  and jut.QUAL6_VALUE_ID is not null
	  and jut.qual6_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id7 terr_qual_id,
      7 qual_num, QUAL7_VALUE_ID qual_value_id,
      QUAL7_VALUE1 qual_VALUE1,
      QUAL7_VALUE2 qual_VALUE2,
      QUAL7_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id7 is not null
	  and jut.QUAL7_VALUE_ID is not null
	  and jut.qual7_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id8 terr_qual_id,
      8 qual_num, QUAL8_VALUE_ID qual_value_id,
      QUAL8_VALUE1 qual_VALUE1,
      QUAL8_VALUE2 qual_VALUE2,
      QUAL8_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id8 is not null
	  and jut.QUAL8_VALUE_ID is not null
	  and jut.qual8_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id9 terr_qual_id,
      9 qual_num, QUAL9_VALUE_ID qual_value_id,
      QUAL9_VALUE1 qual_VALUE1,
      QUAL9_VALUE2 qual_VALUE2,
      QUAL9_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id9 is not null
	  and jut.QUAL9_VALUE_ID is not null
	  and jut.qual9_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id10 terr_qual_id,
      10 qual_num, QUAL10_VALUE_ID qual_value_id,
      QUAL10_VALUE1 qual_VALUE1,
      QUAL10_VALUE2 qual_VALUE2,
      QUAL10_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id10 is not null
	  and jut.QUAL10_VALUE_ID is not null
	  and jut.qual10_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id11 terr_qual_id,
      11 qual_num, QUAL11_VALUE_ID qual_value_id,
      QUAL11_VALUE1 qual_VALUE1,
      QUAL11_VALUE2 qual_VALUE2,
      QUAL11_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id11 is not null
	  and jut.QUAL11_VALUE_ID is not null
	  and jut.qual11_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id12 terr_qual_id,
      12 qual_num, QUAL12_VALUE_ID qual_value_id,
      QUAL12_VALUE1 qual_VALUE1,
      QUAL12_VALUE2 qual_VALUE2,
      QUAL12_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id12 is not null
	  and jut.QUAL12_VALUE_ID is not null
	  and jut.qual12_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id13 terr_qual_id,
      13 qual_num, QUAL13_VALUE_ID qual_value_id,
      QUAL13_VALUE1 qual_VALUE1,
      QUAL13_VALUE2 qual_VALUE2,
      QUAL13_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id13 is not null
	  and jut.QUAL13_VALUE_ID is not null
	  and jut.qual13_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id14 terr_qual_id,
      14 qual_num, QUAL14_VALUE_ID qual_value_id,
      QUAL14_VALUE1 qual_VALUE1,
      QUAL14_VALUE2 qual_VALUE2,
      QUAL14_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id14 is not null
	  and jut.QUAL14_VALUE_ID is not null
	  and jut.qual14_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id15 terr_qual_id,
      15 qual_num, QUAL15_VALUE_ID qual_value_id,
      QUAL15_VALUE1 qual_VALUE1,
      QUAL15_VALUE2 qual_VALUE2,
      QUAL15_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id15 is not null
	  and jut.QUAL15_VALUE_ID is not null
	  and jut.qual15_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id16 terr_qual_id,
      16 qual_num, QUAL16_VALUE_ID qual_value_id,
      QUAL16_VALUE1 qual_VALUE1,
      QUAL16_VALUE2 qual_VALUE2,
      QUAL16_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id16 is not null
	  and jut.QUAL16_VALUE_ID is not null
	  and jut.qual16_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id17 terr_qual_id,
      17 qual_num, QUAL17_VALUE_ID qual_value_id,
      QUAL17_VALUE1 qual_VALUE1,
      QUAL17_VALUE2 qual_VALUE2,
      QUAL17_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id17 is not null
	  and jut.QUAL17_VALUE_ID is not null
	  and jut.qual17_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id18 terr_qual_id,
      18 qual_num, QUAL18_VALUE_ID qual_value_id,
      QUAL18_VALUE1 qual_VALUE1,
      QUAL18_VALUE2 qual_VALUE2,
      QUAL18_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id18 is not null
	  and jut.QUAL18_VALUE_ID is not null
	  and jut.qual18_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id19 terr_qual_id,
      19 qual_num, QUAL19_VALUE_ID qual_value_id,
      QUAL19_VALUE1 qual_VALUE1,
      QUAL19_VALUE2 qual_VALUE2,
      QUAL19_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id19 is not null
	  and jut.QUAL19_VALUE_ID is not null
	  and jut.qual19_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id20 terr_qual_id,
      20 qual_num, QUAL20_VALUE_ID qual_value_id,
      QUAL20_VALUE1 qual_VALUE1,
      QUAL20_VALUE2 qual_VALUE2,
      QUAL20_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id20 is not null
	  and jut.QUAL20_VALUE_ID is not null
	  and jut.qual20_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id21 terr_qual_id,
      21 qual_num, QUAL21_VALUE_ID qual_value_id,
      QUAL21_VALUE1 qual_VALUE1,
      QUAL21_VALUE2 qual_VALUE2,
      QUAL21_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id21 is not null
	  and jut.QUAL21_VALUE_ID is not null
	  and jut.qual21_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id22 terr_qual_id,
      22 qual_num, QUAL22_VALUE_ID qual_value_id,
      QUAL22_VALUE1 qual_VALUE1,
      QUAL22_VALUE2 qual_VALUE2,
      QUAL22_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id22 is not null
	  and jut.QUAL22_VALUE_ID is not null
	  and jut.qual22_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id23 terr_qual_id,
      23 qual_num, QUAL23_VALUE_ID qual_value_id,
      QUAL23_VALUE1 qual_VALUE1,
      QUAL23_VALUE2 qual_VALUE2,
      QUAL23_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id23 is not null
	  and jut.QUAL23_VALUE_ID is not null
	  and jut.qual23_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id24 terr_qual_id,
      24 qual_num, QUAL24_VALUE_ID qual_value_id,
      QUAL24_VALUE1 qual_VALUE1,
      QUAL24_VALUE2 qual_VALUE2,
      QUAL24_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id24 is not null
	  and jut.QUAL24_VALUE_ID is not null
	  and jut.qual24_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id25 terr_qual_id,
      25 qual_num, QUAL25_VALUE_ID qual_value_id,
      QUAL25_VALUE1 qual_valUE1,
      QUAL25_VALUE2 qual_valUE2,
      QUAL25_VALUE3 qual_valUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id25 is not null
	  and jut.QUAL25_VALUE_ID is not null
	  and jut.qual25_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id26 terr_qual_id,
      26 qual_num, QUAL26_VALUE_ID qual_value_id,
      QUAL26_VALUE1 qual_VALUE1,
      QUAL26_VALUE2 qual_VALUE2,
      QUAL26_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id26 is not null
	  and jut.QUAL26_VALUE_ID is not null
	  and jut.QUAL26_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id27 terr_qual_id,
      27 qual_num, QUAL27_VALUE_ID qual_value_id,
      QUAL27_VALUE1 qual_VALUE1,
      QUAL27_VALUE2 qual_VALUE2,
      QUAL27_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id27 is not null
	  and jut.QUAL27_VALUE_ID is not null
	  and jut.QUAL27_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id28 terr_qual_id,
      28 qual_num, QUAL28_VALUE_ID qual_value_id,
      QUAL28_VALUE1 qual_VALUE1,
      QUAL28_VALUE2 qual_VALUE2,
      QUAL28_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id28 is not null
	  and jut.QUAL28_VALUE_ID is not null
	  and jut.QUAL28_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id29 terr_qual_id,
      29 qual_num, QUAL29_VALUE_ID qual_value_id,
      QUAL29_VALUE1 qual_VALUE1,
      QUAL29_VALUE2 qual_VALUE2,
      QUAL29_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id29 is not null
	  and jut.QUAL29_VALUE_ID is not null
	  and jut.QUAL29_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id30 terr_qual_id,
      30 qual_num, QUAL30_VALUE_ID qual_value_id,
      QUAL30_VALUE1 qual_VALUE1,
      QUAL30_VALUE2 qual_VALUE2,
      QUAL30_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id30 is not null
	  and jut.QUAL30_VALUE_ID is not null
	  and jut.QUAL30_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id31 terr_qual_id,
      31 qual_num, QUAL31_VALUE_ID qual_value_id,
      QUAL31_VALUE1 qual_VALUE1,
      QUAL31_VALUE2 qual_VALUE2,
      QUAL31_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id31 is not null
	  and jut.QUAL31_VALUE_ID is not null
	  and jut.QUAL31_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id32 terr_qual_id,
      32 qual_num, QUAL32_VALUE_ID qual_value_id,
      QUAL32_VALUE1 qual_VALUE1,
      QUAL32_VALUE2 qual_VALUE2,
      QUAL32_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id32 is not null
	  and jut.QUAL32_VALUE_ID is not null
	  and jut.QUAL32_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id33 terr_qual_id,
      33 qual_num, QUAL33_VALUE_ID qual_value_id,
      QUAL33_VALUE1 qual_VALUE1,
      QUAL33_VALUE2 qual_VALUE2,
      QUAL33_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id33 is not null
	  and jut.QUAL33_VALUE_ID is not null
	  and jut.QUAL33_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id34 terr_qual_id,
      34 qual_num, QUAL34_VALUE_ID qual_value_id,
      QUAL34_VALUE1 qual_VALUE1,
      QUAL34_VALUE2 qual_VALUE2,
      QUAL34_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id34 is not null
	  and jut.QUAL34_VALUE_ID is not null
	  and jut.QUAL34_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id35 terr_qual_id,
      35 qual_num, QUAL35_VALUE_ID qual_value_id,
      QUAL35_VALUE1 qual_valUE1,
      QUAL35_VALUE2 qual_valUE2,
      QUAL35_VALUE3 qual_valUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id35 is not null
	  and jut.QUAL35_VALUE_ID is not null
	  and jut.QUAL35_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id36 terr_qual_id,
      36 qual_num, QUAL36_VALUE_ID qual_value_id,
      QUAL36_VALUE1 qual_VALUE1,
      QUAL36_VALUE2 qual_VALUE2,
      QUAL36_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id36 is not null
	  and jut.QUAL36_VALUE_ID is not null
	  and jut.QUAL36_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id37 terr_qual_id,
      37 qual_num, QUAL37_VALUE_ID qual_value_id,
      QUAL37_VALUE1 qual_VALUE1,
      QUAL37_VALUE2 qual_VALUE2,
      QUAL37_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id37 is not null
	  and jut.QUAL37_VALUE_ID is not null
	  and jut.QUAL37_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id38 terr_qual_id,
      38 qual_num, QUAL38_VALUE_ID qual_value_id,
      QUAL38_VALUE1 qual_VALUE1,
      QUAL38_VALUE2 qual_VALUE2,
      QUAL38_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id38 is not null
	  and jut.QUAL38_VALUE_ID is not null
	  and jut.QUAL38_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id39 terr_qual_id,
      39 qual_num, QUAL39_VALUE_ID qual_value_id,
      QUAL39_VALUE1 qual_VALUE1,
      QUAL39_VALUE2 qual_VALUE2,
      QUAL39_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id39 is not null
	  and jut.QUAL39_VALUE_ID is not null
	  and jut.QUAL39_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id40 terr_qual_id,
      40 qual_num, QUAL40_VALUE_ID qual_value_id,
      QUAL40_VALUE1 qual_VALUE1,
      QUAL40_VALUE2 qual_VALUE2,
      QUAL40_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id40 is not null
	  and jut.QUAL40_VALUE_ID is not null
	  and jut.QUAL40_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id41 terr_qual_id,
      41 qual_num, QUAL41_VALUE_ID qual_value_id,
      QUAL41_VALUE1 qual_VALUE1,
      QUAL41_VALUE2 qual_VALUE2,
      QUAL41_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id41 is not null
	  and jut.QUAL41_VALUE_ID is not null
	  and jut.QUAL41_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id42 terr_qual_id,
      42 qual_num, QUAL42_VALUE_ID qual_value_id,
      QUAL42_VALUE1 qual_VALUE1,
      QUAL42_VALUE2 qual_VALUE2,
      QUAL42_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id42 is not null
	  and jut.QUAL42_VALUE_ID is not null
	  and jut.QUAL42_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id43 terr_qual_id,
      43 qual_num, QUAL43_VALUE_ID qual_value_id,
      QUAL43_VALUE1 qual_VALUE1,
      QUAL43_VALUE2 qual_VALUE2,
      QUAL43_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id43 is not null
	  and jut.QUAL43_VALUE_ID is not null
	  and jut.QUAL43_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id44 terr_qual_id,
      44 qual_num, QUAL44_VALUE_ID qual_value_id,
      QUAL44_VALUE1 qual_VALUE1,
      QUAL44_VALUE2 qual_VALUE2,
      QUAL44_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id44 is not null
	  and jut.QUAL44_VALUE_ID is not null
	  and jut.QUAL44_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id45 terr_qual_id,
      45 qual_num, QUAL45_VALUE_ID qual_value_id,
      QUAL45_VALUE1 qual_valUE1,
      QUAL45_VALUE2 qual_valUE2,
      QUAL45_VALUE3 qual_valUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id45 is not null
	  and jut.QUAL45_VALUE_ID is not null
	  and jut.QUAL45_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id46 terr_qual_id,
      46 qual_num, QUAL46_VALUE_ID qual_value_id,
      QUAL46_VALUE1 qual_VALUE1,
      QUAL46_VALUE2 qual_VALUE2,
      QUAL46_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id46 is not null
	  and jut.QUAL46_VALUE_ID is not null
	  and jut.QUAL46_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id47 terr_qual_id,
      47 qual_num, QUAL47_VALUE_ID qual_value_id,
      QUAL47_VALUE1 qual_VALUE1,
      QUAL47_VALUE2 qual_VALUE2,
      QUAL47_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id47 is not null
	  and jut.QUAL47_VALUE_ID is not null
	  and jut.QUAL47_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id48 terr_qual_id,
      48 qual_num, QUAL48_VALUE_ID qual_value_id,
      QUAL48_VALUE1 qual_VALUE1,
      QUAL48_VALUE2 qual_VALUE2,
      QUAL48_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id48 is not null
	  and jut.QUAL48_VALUE_ID is not null
	  and jut.QUAL48_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id49 terr_qual_id,
      49 qual_num, QUAL49_VALUE_ID qual_value_id,
      QUAL49_VALUE1 qual_VALUE1,
      QUAL49_VALUE2 qual_VALUE2,
      QUAL49_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id49 is not null
	  and jut.QUAL49_VALUE_ID is not null
	  and jut.QUAL49_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id50 terr_qual_id,
      50 qual_num, QUAL50_VALUE_ID qual_value_id,
      QUAL50_VALUE1 qual_VALUE1,
      QUAL50_VALUE2 qual_VALUE2,
      QUAL50_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id50 is not null
	  and jut.QUAL50_VALUE_ID is not null
	  and jut.QUAL50_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id51 terr_qual_id,
      51 qual_num, QUAL51_VALUE_ID qual_value_id,
      QUAL51_VALUE1 qual_VALUE1,
      QUAL51_VALUE2 qual_VALUE2,
      QUAL51_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id51 is not null
	  and jut.QUAL51_VALUE_ID is not null
	  and jut.QUAL51_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id52 terr_qual_id,
      52 qual_num, QUAL52_VALUE_ID qual_value_id,
      QUAL52_VALUE1 qual_VALUE1,
      QUAL52_VALUE2 qual_VALUE2,
      QUAL52_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id52 is not null
	  and jut.QUAL52_VALUE_ID is not null
	  and jut.QUAL52_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id53 terr_qual_id,
      53 qual_num, QUAL53_VALUE_ID qual_value_id,
      QUAL53_VALUE1 qual_VALUE1,
      QUAL53_VALUE2 qual_VALUE2,
      QUAL53_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id53 is not null
	  and jut.QUAL53_VALUE_ID is not null
	  and jut.QUAL53_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id54 terr_qual_id,
      54 qual_num, QUAL54_VALUE_ID qual_value_id,
      QUAL54_VALUE1 qual_VALUE1,
      QUAL54_VALUE2 qual_VALUE2,
      QUAL54_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id54 is not null
	  and jut.QUAL54_VALUE_ID is not null
	  and jut.QUAL54_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id55 terr_qual_id,
      55 qual_num, QUAL55_VALUE_ID qual_value_id,
      QUAL55_VALUE1 qual_valUE1,
      QUAL55_VALUE2 qual_valUE2,
      QUAL55_VALUE3 qual_valUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id55 is not null
	  and jut.QUAL55_VALUE_ID is not null
	  and jut.QUAL55_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id56 terr_qual_id,
      56 qual_num, QUAL56_VALUE_ID qual_value_id,
      QUAL56_VALUE1 qual_VALUE1,
      QUAL56_VALUE2 qual_VALUE2,
      QUAL56_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id56 is not null
	  and jut.QUAL56_VALUE_ID is not null
	  and jut.QUAL56_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id57 terr_qual_id,
      57 qual_num, QUAL57_VALUE_ID qual_value_id,
      QUAL57_VALUE1 qual_VALUE1,
      QUAL57_VALUE2 qual_VALUE2,
      QUAL57_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id57 is not null
	  and jut.QUAL57_VALUE_ID is not null
	  and jut.QUAL57_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id58 terr_qual_id,
      58 qual_num, QUAL58_VALUE_ID qual_value_id,
      QUAL58_VALUE1 qual_VALUE1,
      QUAL58_VALUE2 qual_VALUE2,
      QUAL58_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id58 is not null
	  and jut.QUAL58_VALUE_ID is not null
	  and jut.QUAL58_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id59 terr_qual_id,
      59 qual_num, QUAL59_VALUE_ID qual_value_id,
      QUAL59_VALUE1 qual_VALUE1,
      QUAL59_VALUE2 qual_VALUE2,
      QUAL59_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id59 is not null
	  and jut.QUAL59_VALUE_ID is not null
	  and jut.QUAL59_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id60 terr_qual_id,
      60 qual_num, QUAL60_VALUE_ID qual_value_id,
      QUAL60_VALUE1 qual_VALUE1,
      QUAL60_VALUE2 qual_VALUE2,
      QUAL60_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id60 is not null
	  and jut.QUAL60_VALUE_ID is not null
	  and jut.QUAL60_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id61 terr_qual_id,
      61 qual_num, QUAL61_VALUE_ID qual_value_id,
      QUAL61_VALUE1 qual_VALUE1,
      QUAL61_VALUE2 qual_VALUE2,
      QUAL61_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id61 is not null
	  and jut.QUAL61_VALUE_ID is not null
	  and jut.QUAL61_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id62 terr_qual_id,
      62 qual_num, QUAL62_VALUE_ID qual_value_id,
      QUAL62_VALUE1 qual_VALUE1,
      QUAL62_VALUE2 qual_VALUE2,
      QUAL62_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id62 is not null
	  and jut.QUAL62_VALUE_ID is not null
	  and jut.QUAL62_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id63 terr_qual_id,
      63 qual_num, QUAL63_VALUE_ID qual_value_id,
      QUAL63_VALUE1 qual_VALUE1,
      QUAL63_VALUE2 qual_VALUE2,
      QUAL63_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id63 is not null
	  and jut.QUAL63_VALUE_ID is not null
	  and jut.QUAL63_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id64 terr_qual_id,
      64 qual_num, QUAL64_VALUE_ID qual_value_id,
      QUAL64_VALUE1 qual_VALUE1,
      QUAL64_VALUE2 qual_VALUE2,
      QUAL64_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id64 is not null
	  and jut.QUAL64_VALUE_ID is not null
	  and jut.QUAL64_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id65 terr_qual_id,
      65 qual_num, QUAL65_VALUE_ID qual_value_id,
      QUAL65_VALUE1 qual_valUE1,
      QUAL65_VALUE2 qual_valUE2,
      QUAL65_VALUE3 qual_valUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id65 is not null
	  and jut.QUAL65_VALUE_ID is not null
	  and jut.QUAL65_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id66 terr_qual_id,
      66 qual_num, QUAL66_VALUE_ID qual_value_id,
      QUAL66_VALUE1 qual_VALUE1,
      QUAL66_VALUE2 qual_VALUE2,
      QUAL66_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id66 is not null
	  and jut.QUAL66_VALUE_ID is not null
	  and jut.QUAL66_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id67 terr_qual_id,
      67 qual_num, QUAL67_VALUE_ID qual_value_id,
      QUAL67_VALUE1 qual_VALUE1,
      QUAL67_VALUE2 qual_VALUE2,
      QUAL67_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id67 is not null
	  and jut.QUAL67_VALUE_ID is not null
	  and jut.QUAL67_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id68 terr_qual_id,
      68 qual_num, QUAL68_VALUE_ID qual_value_id,
      QUAL68_VALUE1 qual_VALUE1,
      QUAL68_VALUE2 qual_VALUE2,
      QUAL68_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id68 is not null
	  and jut.QUAL68_VALUE_ID is not null
	  and jut.QUAL68_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id69 terr_qual_id,
      69 qual_num, QUAL69_VALUE_ID qual_value_id,
      QUAL69_VALUE1 qual_VALUE1,
      QUAL69_VALUE2 qual_VALUE2,
      QUAL69_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id69 is not null
	  and jut.QUAL69_VALUE_ID is not null
	  and jut.QUAL69_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id70 terr_qual_id,
      70 qual_num, QUAL70_VALUE_ID qual_value_id,
      QUAL70_VALUE1 qual_VALUE1,
      QUAL70_VALUE2 qual_VALUE2,
      QUAL70_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id70 is not null
	  and jut.QUAL70_VALUE_ID is not null
	  and jut.QUAL70_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id71 terr_qual_id,
      71 qual_num, QUAL71_VALUE_ID qual_value_id,
      QUAL71_VALUE1 qual_VALUE1,
      QUAL71_VALUE2 qual_VALUE2,
      QUAL71_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id71 is not null
	  and jut.QUAL71_VALUE_ID is not null
	  and jut.QUAL71_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id72 terr_qual_id,
      72 qual_num, QUAL72_VALUE_ID qual_value_id,
      QUAL72_VALUE1 qual_VALUE1,
      QUAL72_VALUE2 qual_VALUE2,
      QUAL72_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id72 is not null
	  and jut.QUAL72_VALUE_ID is not null
	  and jut.QUAL72_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id73 terr_qual_id,
      73 qual_num, QUAL73_VALUE_ID qual_value_id,
      QUAL73_VALUE1 qual_VALUE1,
      QUAL73_VALUE2 qual_VALUE2,
      QUAL73_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id73 is not null
	  and jut.QUAL73_VALUE_ID is not null
	  and jut.QUAL73_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id74 terr_qual_id,
      74 qual_num, QUAL74_VALUE_ID qual_value_id,
      QUAL74_VALUE1 qual_VALUE1,
      QUAL74_VALUE2 qual_VALUE2,
      QUAL74_VALUE3 qual_VALUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id74 is not null
	  and jut.QUAL74_VALUE_ID is not null
	  and jut.QUAL74_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id75 terr_qual_id,
      75 qual_num, QUAL75_VALUE_ID qual_value_id,
      QUAL75_VALUE1 qual_valUE1,
      QUAL75_VALUE2 qual_valUE2,
      QUAL75_VALUE3 qual_valUE3, ORG_ID,
      LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id75 is not null
	  and jut.QUAL75_VALUE_ID is not null
	  and jut.QUAL75_value1 is not null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
	  ) sub
      where jq.user_sequence = sub.user_sequence
        and jq.qualifier_num = sub.qual_num;

	CURSOR get_d_terr_value_csr(
	  v_user_sequence number,
	  v_action_flag	  varchar2,
	  v_intf_type	  varchar2,
	  v_header		  varchar2) IS
    select sub.TERR_QUAL_ID, sub.terr_id, sub.qual_value_id,
	sub.qual_num
      from (
      select terr_id, user_sequence,
	  terr_qual_id1 terr_qual_id,
      1 qual_num, QUAL1_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id1 is not null
	  and jut.QUAL1_VALUE_ID is not null
	  and jut.qual1_value1 is null
      and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id2 terr_qual_id,
      2 qual_num, QUAL2_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id2 is not null
	  and jut.QUAL2_VALUE_ID is not null
	  and jut.qual2_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id3 terr_qual_id,
      3 qual_num, QUAL3_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id3 is not null
	  and jut.QUAL3_VALUE_ID is not null
	  and jut.qual3_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id4 terr_qual_id,
      4 qual_num, QUAL4_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id4 is not null
	  and jut.QUAL4_VALUE_ID is not null
	  and jut.qual4_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id5 terr_qual_id,
      5 qual_num, QUAL5_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id5 is not null
	  and jut.QUAL5_VALUE_ID is not null
	  and jut.qual5_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id6 terr_qual_id,
      6 qual_num, QUAL6_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id6 is not null
	  and jut.QUAL6_VALUE_ID is not null
	  and jut.qual6_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id7 terr_qual_id,
      7 qual_num, QUAL7_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id7 is not null
	  and jut.QUAL7_VALUE_ID is not null
	  and jut.qual7_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id8 terr_qual_id,
      8 qual_num, QUAL8_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id8 is not null
	  and jut.QUAL8_VALUE_ID is not null
	  and jut.qual8_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id9 terr_qual_id,
      9 qual_num, QUAL9_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id9 is not null
	  and jut.QUAL9_VALUE_ID is not null
	  and jut.qual9_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id10 terr_qual_id,
      10 qual_num, QUAL10_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id10 is not null
	  and jut.QUAL10_VALUE_ID is not null
	  and jut.qual10_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id11 terr_qual_id,
      11 qual_num, QUAL11_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id11 is not null
	  and jut.QUAL11_VALUE_ID is not null
	  and jut.qual11_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id12 terr_qual_id,
      12 qual_num, QUAL12_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id12 is not null
	  and jut.QUAL12_VALUE_ID is not null
	  and jut.qual12_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id13 terr_qual_id,
      13 qual_num, QUAL13_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id13 is not null
	  and jut.QUAL13_VALUE_ID is not null
	  and jut.qual13_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id14 terr_qual_id,
      14 qual_num, QUAL14_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id14 is not null
	  and jut.QUAL14_VALUE_ID is not null
	  and jut.qual14_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id15 terr_qual_id,
      15 qual_num, QUAL15_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id15 is not null
	  and jut.QUAL15_VALUE_ID is not null
	  and jut.qual15_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id16 terr_qual_id,
      16 qual_num, QUAL16_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id16 is not null
	  and jut.QUAL16_VALUE_ID is not null
	  and jut.qual16_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id17 terr_qual_id,
      17 qual_num, QUAL17_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id17 is not null
	  and jut.QUAL17_VALUE_ID is not null
	  and jut.qual17_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id18 terr_qual_id,
      18 qual_num, QUAL18_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id18 is not null
	  and jut.QUAL18_VALUE_ID is not null
	  and jut.qual18_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id19 terr_qual_id,
      19 qual_num, QUAL19_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id19 is not null
	  and jut.QUAL19_VALUE_ID is not null
	  and jut.qual19_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id20 terr_qual_id,
      20 qual_num, QUAL20_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id20 is not null
	  and jut.QUAL20_VALUE_ID is not null
	  and jut.qual20_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id21 terr_qual_id,
      21 qual_num, QUAL21_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id21 is not null
	  and jut.QUAL21_VALUE_ID is not null
	  and jut.qual21_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id22 terr_qual_id,
      22 qual_num, QUAL22_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id22 is not null
	  and jut.QUAL22_VALUE_ID is not null
	  and jut.qual22_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id23 terr_qual_id,
      23 qual_num, QUAL23_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id23 is not null
	  and jut.QUAL23_VALUE_ID is not null
	  and jut.qual23_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id24 terr_qual_id,
      24 qual_num, QUAL24_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id24 is not null
	  and jut.QUAL24_VALUE_ID is not null
	  and jut.qual24_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id25 terr_qual_id,
      25 qual_num, QUAL25_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id25 is not null
	  and jut.QUAL25_VALUE_ID is not null
	  and jut.qual25_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id26 terr_qual_id,
      26 qual_num, QUAL26_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id26 is not null
	  and jut.QUAL26_VALUE_ID is not null
	  and jut.QUAL26_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id27 terr_qual_id,
      27 qual_num, QUAL27_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id27 is not null
	  and jut.QUAL27_VALUE_ID is not null
	  and jut.QUAL27_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id28 terr_qual_id,
      28 qual_num, QUAL28_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id28 is not null
	  and jut.QUAL28_VALUE_ID is not null
	  and jut.QUAL28_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id29 terr_qual_id,
      29 qual_num, QUAL29_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id29 is not null
	  and jut.QUAL29_VALUE_ID is not null
	  and jut.QUAL29_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
	  select terr_id, user_sequence,
	  terr_qual_id30 terr_qual_id,
      30 qual_num, QUAL30_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id30 is not null
	  and jut.QUAL30_VALUE_ID is not null
	  and jut.QUAL30_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id31 terr_qual_id,
      31 qual_num, QUAL31_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id31 is not null
	  and jut.QUAL31_VALUE_ID is not null
	  and jut.QUAL31_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id32 terr_qual_id,
      32 qual_num, QUAL32_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id32 is not null
	  and jut.QUAL32_VALUE_ID is not null
	  and jut.QUAL32_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id33 terr_qual_id,
      33 qual_num, QUAL33_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id33 is not null
	  and jut.QUAL33_VALUE_ID is not null
	  and jut.QUAL33_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id34 terr_qual_id,
      34 qual_num, QUAL34_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id34 is not null
	  and jut.QUAL34_VALUE_ID is not null
	  and jut.QUAL34_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id35 terr_qual_id,
      35 qual_num, QUAL35_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id35 is not null
	  and jut.QUAL35_VALUE_ID is not null
	  and jut.QUAL35_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id36 terr_qual_id,
      36 qual_num, QUAL36_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id36 is not null
	  and jut.QUAL36_VALUE_ID is not null
	  and jut.QUAL36_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id37 terr_qual_id,
      37 qual_num, QUAL37_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id37 is not null
	  and jut.QUAL37_VALUE_ID is not null
	  and jut.QUAL37_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id38 terr_qual_id,
      38 qual_num, QUAL38_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id38 is not null
	  and jut.QUAL38_VALUE_ID is not null
	  and jut.QUAL38_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id39 terr_qual_id,
      39 qual_num, QUAL39_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id39 is not null
	  and jut.QUAL39_VALUE_ID is not null
	  and jut.QUAL39_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id40 terr_qual_id,
      40 qual_num, QUAL40_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id40 is not null
	  and jut.QUAL40_VALUE_ID is not null
	  and jut.QUAL40_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id41 terr_qual_id,
      41 qual_num, QUAL41_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id41 is not null
	  and jut.QUAL41_VALUE_ID is not null
	  and jut.QUAL41_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id42 terr_qual_id,
      42 qual_num, QUAL42_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id42 is not null
	  and jut.QUAL42_VALUE_ID is not null
	  and jut.QUAL42_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id43 terr_qual_id,
      43 qual_num, QUAL43_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id43 is not null
	  and jut.QUAL43_VALUE_ID is not null
	  and jut.QUAL43_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id44 terr_qual_id,
      44 qual_num, QUAL44_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id44 is not null
	  and jut.QUAL44_VALUE_ID is not null
	  and jut.QUAL44_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id45 terr_qual_id,
      45 qual_num, QUAL45_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id45 is not null
	  and jut.QUAL45_VALUE_ID is not null
	  and jut.QUAL45_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id46 terr_qual_id,
      46 qual_num, QUAL46_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id46 is not null
	  and jut.QUAL46_VALUE_ID is not null
	  and jut.QUAL46_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id47 terr_qual_id,
      47 qual_num, QUAL47_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id47 is not null
	  and jut.QUAL47_VALUE_ID is not null
	  and jut.QUAL47_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id48 terr_qual_id,
      48 qual_num, QUAL48_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id48 is not null
	  and jut.QUAL48_VALUE_ID is not null
	  and jut.QUAL48_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id49 terr_qual_id,
      49 qual_num, QUAL49_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id49 is not null
	  and jut.QUAL49_VALUE_ID is not null
	  and jut.QUAL49_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id50 terr_qual_id,
      50 qual_num, QUAL50_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id50 is not null
	  and jut.QUAL50_VALUE_ID is not null
	  and jut.QUAL50_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id51 terr_qual_id,
      51 qual_num, QUAL51_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id51 is not null
	  and jut.QUAL51_VALUE_ID is not null
	  and jut.QUAL51_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id52 terr_qual_id,
      52 qual_num, QUAL52_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id52 is not null
	  and jut.QUAL52_VALUE_ID is not null
	  and jut.QUAL52_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id53 terr_qual_id,
      53 qual_num, QUAL53_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id53 is not null
	  and jut.QUAL53_VALUE_ID is not null
	  and jut.QUAL53_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id54 terr_qual_id,
      54 qual_num, QUAL54_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id54 is not null
	  and jut.QUAL54_VALUE_ID is not null
	  and jut.QUAL54_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id55 terr_qual_id,
      55 qual_num, QUAL55_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id55 is not null
	  and jut.QUAL55_VALUE_ID is not null
	  and jut.QUAL55_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id56 terr_qual_id,
      56 qual_num, QUAL56_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id56 is not null
	  and jut.QUAL56_VALUE_ID is not null
	  and jut.QUAL56_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id57 terr_qual_id,
      57 qual_num, QUAL57_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id57 is not null
	  and jut.QUAL57_VALUE_ID is not null
	  and jut.QUAL57_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id58 terr_qual_id,
      58 qual_num, QUAL58_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id58 is not null
	  and jut.QUAL58_VALUE_ID is not null
	  and jut.QUAL58_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id59 terr_qual_id,
      59 qual_num, QUAL59_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id59 is not null
	  and jut.QUAL59_VALUE_ID is not null
	  and jut.QUAL59_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id60 terr_qual_id,
      60 qual_num, QUAL60_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id60 is not null
	  and jut.QUAL60_VALUE_ID is not null
	  and jut.QUAL60_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id61 terr_qual_id,
      61 qual_num, QUAL61_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id61 is not null
	  and jut.QUAL61_VALUE_ID is not null
	  and jut.QUAL61_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id62 terr_qual_id,
      62 qual_num, QUAL62_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id62 is not null
	  and jut.QUAL62_VALUE_ID is not null
	  and jut.QUAL62_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id63 terr_qual_id,
      63 qual_num, QUAL63_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id63 is not null
	  and jut.QUAL63_VALUE_ID is not null
	  and jut.QUAL63_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id64 terr_qual_id,
      64 qual_num, QUAL64_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id64 is not null
	  and jut.QUAL64_VALUE_ID is not null
	  and jut.QUAL64_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id65 terr_qual_id,
      65 qual_num, QUAL65_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id65 is not null
	  and jut.QUAL65_VALUE_ID is not null
	  and jut.QUAL65_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id66 terr_qual_id,
      66 qual_num, QUAL66_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id66 is not null
	  and jut.QUAL66_VALUE_ID is not null
	  and jut.QUAL66_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id67 terr_qual_id,
      67 qual_num, QUAL67_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id67 is not null
	  and jut.QUAL67_VALUE_ID is not null
	  and jut.QUAL67_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id68 terr_qual_id,
      68 qual_num, QUAL68_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id68 is not null
	  and jut.QUAL68_VALUE_ID is not null
	  and jut.QUAL68_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id69 terr_qual_id,
      69 qual_num, QUAL69_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id69 is not null
	  and jut.QUAL69_VALUE_ID is not null
	  and jut.QUAL69_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
	  select terr_id, user_sequence,
	  terr_qual_id70 terr_qual_id,
      70 qual_num, QUAL70_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id70 is not null
	  and jut.QUAL70_VALUE_ID is not null
	  and jut.QUAL70_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id71 terr_qual_id,
      71 qual_num, QUAL71_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id71 is not null
	  and jut.QUAL71_VALUE_ID is not null
	  and jut.QUAL71_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id72 terr_qual_id,
      72 qual_num, QUAL72_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id72 is not null
	  and jut.QUAL72_VALUE_ID is not null
	  and jut.QUAL72_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id73 terr_qual_id,
      73 qual_num, QUAL73_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id73 is not null
	  and jut.QUAL73_VALUE_ID is not null
	  and jut.QUAL73_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id74 terr_qual_id,
      74 qual_num, QUAL74_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id74 is not null
	  and jut.QUAL74_VALUE_ID is not null
	  and jut.QUAL74_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
      union all
      select terr_id, user_sequence,
	  terr_qual_id75 terr_qual_id,
      75 qual_num, QUAL75_VALUE_ID qual_value_id
      FROM JTY_WEBADI_OTH_TERR_INTF jut
      where jut.USER_SEQUENCE = v_user_sequence
  	  and jut.status is null
	  and jut.terr_qual_id75 is not null
	  and jut.QUAL75_VALUE_ID is not null
	  and jut.QUAL75_value1 is null
  	  and jut.INTERFACE_TYPE = v_intf_type
	  AND jut.ACTION_FLAG = v_action_flag
  	  and jut.header = v_header
	  ) sub;

	l_Terr_Qual_Rec		Terr_Qual_Rec_Type;
	l_terr_values_rec 	Terr_values_rec_type;
	l_terr_values_out_rec Terr_values_out_rec_type;

    l_intf_type VARCHAR2(1) := 'U';
	l_header	varchar2(15)  := 'QUAL';
	l_action_flag varchar2(1);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_data := NULL;
  debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_QUAL  : Inside' );
  --l_action_flag := p_action_flag;
  l_action_flag := 'C';
  debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_QUAL  : l_action_flag :'  || l_action_flag);
  debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_QUAL  : l_intf_type :'  || l_intf_type);
  debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_QUAL  : l_header :'  || l_header);
  open get_qual_csr(P_USER_SEQUENCE, l_action_flag, l_intf_type, l_header);
  fetch get_qual_csr bulk collect into
	l_Terr_Qual_Rec.TERR_QUAL_ID, l_Terr_Qual_Rec.terr_id,
	l_Terr_Qual_Rec.qual_value_id, l_Terr_Qual_Rec.qual_value1,
	l_Terr_Qual_Rec.qual_value2, l_Terr_Qual_Rec.qual_value3,
  	l_Terr_Qual_Rec.org_id, l_Terr_Qual_Rec.last_updated_by,
	l_Terr_Qual_Rec.last_update_date, l_Terr_Qual_Rec.last_update_login,
	l_Terr_Qual_Rec.creation_date, l_Terr_Qual_Rec.created_by,
  	l_Terr_Qual_Rec.qual_usg_id, l_Terr_Qual_Rec.qual_type,
	l_Terr_Qual_Rec.CONVERT_TO_ID_FLAG, l_Terr_Qual_Rec.qualifier_num,
	l_Terr_Qual_Rec.html_lov_sql1, l_Terr_Qual_Rec.qual_cond;
  close get_qual_csr;

  debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_QUAL  : l_Terr_Qual_Rec.TERR_ID.count :'  || l_Terr_Qual_Rec.TERR_ID.count);
  if (l_action_flag = 'C' AND l_Terr_Qual_Rec.TERR_ID.count > 0) then
    debugmsg('UPDATE_TERR_DEF: INSERT_TERR_QUAL  : Before ' );
    INSERT_TERR_QUAL (
      p_Terr_Qual_Rec	=> l_Terr_Qual_Rec,
   	  x_return_status	=> x_return_status,
      x_msg_data		=> x_msg_data);
    debugmsg('UPDATE_TERR_DEF: INSERT_TERR_QUAL  : After completion x_return_status : ' || x_return_status);
    if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
    debugmsg('UPDATE_TERR_DEF: INSERT_TERR_VALUES  : Before ' );
      INSERT_TERR_VALUES(
     	p_Terr_Qual_Rec	=> l_terr_qual_rec,
     	p_terr_values_out_rec => l_terr_values_out_rec,
     	x_return_status		  => x_return_status,
     	x_msg_data			  => x_msg_data);
     	debugmsg('UPDATE_TERR_DEF: INSERT_TERR_VALUES  : After completion x_return_status : ' || x_return_status);
     	debugmsg('UPDATE_TERR_DEF: INSERT_TERR_VALUES  : After completion x_msg_data : ' || x_msg_data);
    end if;
        debugmsg('UPDATE_TERR_DEF: Update Terr qual id : ');
    forall i in l_Terr_Qual_Rec.TERR_ID.first..l_Terr_Qual_Rec.TERR_ID.last
	  UPDATE JTY_WEBADI_OTH_TERR_INTF jwot
	  set
	  jwot.terr_qual_id1 = decode(l_Terr_Qual_Rec.qualifier_num(i),1,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id1),
	  jwot.terr_qual_id2 = decode(l_Terr_Qual_Rec.qualifier_num(i),2,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id2),
	  jwot.terr_qual_id3 = decode(l_Terr_Qual_Rec.qualifier_num(i),3,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id3),
	  jwot.terr_qual_id4 = decode(l_Terr_Qual_Rec.qualifier_num(i),4,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id4),
	  jwot.terr_qual_id5 = decode(l_Terr_Qual_Rec.qualifier_num(i),5,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id5),
	  jwot.terr_qual_id6 = decode(l_Terr_Qual_Rec.qualifier_num(i),6,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id6),
	  jwot.terr_qual_id7 = decode(l_Terr_Qual_Rec.qualifier_num(i),7,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id7),
	  jwot.terr_qual_id8 = decode(l_Terr_Qual_Rec.qualifier_num(i),8,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id8),
	  jwot.terr_qual_id9 = decode(l_Terr_Qual_Rec.qualifier_num(i),9,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id9),
	  jwot.terr_qual_id10 = decode(l_Terr_Qual_Rec.qualifier_num(i),10,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id10),
	  jwot.terr_qual_id11 = decode(l_Terr_Qual_Rec.qualifier_num(i),11,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id11),
	  jwot.terr_qual_id12 = decode(l_Terr_Qual_Rec.qualifier_num(i),12,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id12),
	  jwot.terr_qual_id13 = decode(l_Terr_Qual_Rec.qualifier_num(i),13,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id13),
	  jwot.terr_qual_id14 = decode(l_Terr_Qual_Rec.qualifier_num(i),14,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id14),
	  jwot.terr_qual_id15 = decode(l_Terr_Qual_Rec.qualifier_num(i),15,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id15),
	  jwot.terr_qual_id16 = decode(l_Terr_Qual_Rec.qualifier_num(i),16,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id16),
	  jwot.terr_qual_id17 = decode(l_Terr_Qual_Rec.qualifier_num(i),17,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id17),
	  jwot.terr_qual_id18 = decode(l_Terr_Qual_Rec.qualifier_num(i),18,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id18),
	  jwot.terr_qual_id19 = decode(l_Terr_Qual_Rec.qualifier_num(i),19,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id19),
	  jwot.terr_qual_id20 = decode(l_Terr_Qual_Rec.qualifier_num(i),20,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id20),
	  jwot.terr_qual_id21 = decode(l_Terr_Qual_Rec.qualifier_num(i),21,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id21),
	  jwot.terr_qual_id22 = decode(l_Terr_Qual_Rec.qualifier_num(i),22,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id22),
	  jwot.terr_qual_id23 = decode(l_Terr_Qual_Rec.qualifier_num(i),23,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id23),
	  jwot.terr_qual_id24 = decode(l_Terr_Qual_Rec.qualifier_num(i),24,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id24),
	  jwot.terr_qual_id25 = decode(l_Terr_Qual_Rec.qualifier_num(i),25,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id25),
	  jwot.terr_qual_id26 = decode(l_Terr_Qual_Rec.qualifier_num(i),26,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id26),
	  jwot.terr_qual_id27 = decode(l_Terr_Qual_Rec.qualifier_num(i),27,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id27),
	  jwot.terr_qual_id28 = decode(l_Terr_Qual_Rec.qualifier_num(i),28,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id28),
	  jwot.terr_qual_id29 = decode(l_Terr_Qual_Rec.qualifier_num(i),29,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id29),
	  jwot.terr_qual_id30 = decode(l_Terr_Qual_Rec.qualifier_num(i),30,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id30),
	  jwot.terr_qual_id31 = decode(l_Terr_Qual_Rec.qualifier_num(i),31,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id31),
	  jwot.terr_qual_id32 = decode(l_Terr_Qual_Rec.qualifier_num(i),32,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id32),
	  jwot.terr_qual_id33 = decode(l_Terr_Qual_Rec.qualifier_num(i),33,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id33),
	  jwot.terr_qual_id34 = decode(l_Terr_Qual_Rec.qualifier_num(i),34,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id34),
	  jwot.terr_qual_id35 = decode(l_Terr_Qual_Rec.qualifier_num(i),35,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id35),
	  jwot.terr_qual_id36 = decode(l_Terr_Qual_Rec.qualifier_num(i),36,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id36),
	  jwot.terr_qual_id37 = decode(l_Terr_Qual_Rec.qualifier_num(i),37,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id37),
	  jwot.terr_qual_id38 = decode(l_Terr_Qual_Rec.qualifier_num(i),38,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id38),
	  jwot.terr_qual_id39 = decode(l_Terr_Qual_Rec.qualifier_num(i),39,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id39),
	  jwot.terr_qual_id40 = decode(l_Terr_Qual_Rec.qualifier_num(i),40,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id40),
	  jwot.terr_qual_id41 = decode(l_Terr_Qual_Rec.qualifier_num(i),41,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id41),
	  jwot.terr_qual_id42 = decode(l_Terr_Qual_Rec.qualifier_num(i),42,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id42),
	  jwot.terr_qual_id43 = decode(l_Terr_Qual_Rec.qualifier_num(i),43,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id43),
	  jwot.terr_qual_id44 = decode(l_Terr_Qual_Rec.qualifier_num(i),44,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id44),
	  jwot.terr_qual_id45 = decode(l_Terr_Qual_Rec.qualifier_num(i),45,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id45),
	  jwot.terr_qual_id46 = decode(l_Terr_Qual_Rec.qualifier_num(i),46,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id46),
	  jwot.terr_qual_id47 = decode(l_Terr_Qual_Rec.qualifier_num(i),47,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id47),
	  jwot.terr_qual_id48 = decode(l_Terr_Qual_Rec.qualifier_num(i),48,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id48),
	  jwot.terr_qual_id49 = decode(l_Terr_Qual_Rec.qualifier_num(i),49,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id49),
	  jwot.terr_qual_id50 = decode(l_Terr_Qual_Rec.qualifier_num(i),50,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id50),
	  jwot.terr_qual_id51 = decode(l_Terr_Qual_Rec.qualifier_num(i),51,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id51),
	  jwot.terr_qual_id52 = decode(l_Terr_Qual_Rec.qualifier_num(i),52,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id52),
	  jwot.terr_qual_id53 = decode(l_Terr_Qual_Rec.qualifier_num(i),53,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id53),
	  jwot.terr_qual_id54 = decode(l_Terr_Qual_Rec.qualifier_num(i),54,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id54),
	  jwot.terr_qual_id55 = decode(l_Terr_Qual_Rec.qualifier_num(i),55,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id55),
	  jwot.terr_qual_id56 = decode(l_Terr_Qual_Rec.qualifier_num(i),56,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id56),
	  jwot.terr_qual_id57 = decode(l_Terr_Qual_Rec.qualifier_num(i),57,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id57),
	  jwot.terr_qual_id58 = decode(l_Terr_Qual_Rec.qualifier_num(i),58,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id58),
	  jwot.terr_qual_id59 = decode(l_Terr_Qual_Rec.qualifier_num(i),59,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id59),
	  jwot.terr_qual_id60 = decode(l_Terr_Qual_Rec.qualifier_num(i),60,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id60),
	  jwot.terr_qual_id61 = decode(l_Terr_Qual_Rec.qualifier_num(i),61,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id61),
	  jwot.terr_qual_id62 = decode(l_Terr_Qual_Rec.qualifier_num(i),62,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id62),
	  jwot.terr_qual_id63 = decode(l_Terr_Qual_Rec.qualifier_num(i),63,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id63),
	  jwot.terr_qual_id64 = decode(l_Terr_Qual_Rec.qualifier_num(i),64,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id64),
	  jwot.terr_qual_id65 = decode(l_Terr_Qual_Rec.qualifier_num(i),65,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id65),
	  jwot.terr_qual_id66 = decode(l_Terr_Qual_Rec.qualifier_num(i),66,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id66),
	  jwot.terr_qual_id67 = decode(l_Terr_Qual_Rec.qualifier_num(i),67,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id67),
	  jwot.terr_qual_id68 = decode(l_Terr_Qual_Rec.qualifier_num(i),68,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id68),
	  jwot.terr_qual_id69 = decode(l_Terr_Qual_Rec.qualifier_num(i),69,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id69),
	  jwot.terr_qual_id70 = decode(l_Terr_Qual_Rec.qualifier_num(i),70,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id70),
	  jwot.terr_qual_id71 = decode(l_Terr_Qual_Rec.qualifier_num(i),71,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id71),
	  jwot.terr_qual_id72 = decode(l_Terr_Qual_Rec.qualifier_num(i),72,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id72),
	  jwot.terr_qual_id73 = decode(l_Terr_Qual_Rec.qualifier_num(i),73,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id73),
	  jwot.terr_qual_id74 = decode(l_Terr_Qual_Rec.qualifier_num(i),74,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id74),
	  jwot.terr_qual_id75 = decode(l_Terr_Qual_Rec.qualifier_num(i),75,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id75)
	  where TERR_ID = l_Terr_Qual_Rec.TERR_ID(i)
	    and user_sequence = p_user_sequence
		and header = l_header
		and interface_type = l_intf_type;

	if x_return_status = FND_API.G_RET_STS_ERROR then
    forall i in l_Terr_Qual_Rec.TERR_QUAL_ID.first..l_Terr_Qual_Rec.TERR_QUAL_ID.last
	  UPDATE JTY_WEBADI_OTH_TERR_INTF jwot
	  SET STATUS = 	x_return_status,
	  ERROR_MSG = x_msg_data
	  WHERE l_Terr_Qual_Rec.TERR_QUAL_ID(i) in
	  		( jwot.TERR_QUAL_ID1, jwot.TERR_QUAL_ID2, jwot.TERR_QUAL_ID3,
			  jwot.TERR_QUAL_ID4, jwot.TERR_QUAL_ID5, jwot.TERR_QUAL_ID6,
			  jwot.TERR_QUAL_ID7, jwot.TERR_QUAL_ID8, jwot.TERR_QUAL_ID9,
			  jwot.TERR_QUAL_ID10, jwot.TERR_QUAL_ID11, jwot.TERR_QUAL_ID12,
			  jwot.TERR_QUAL_ID13, jwot.TERR_QUAL_ID14, jwot.TERR_QUAL_ID15,
			  jwot.TERR_QUAL_ID16, jwot.TERR_QUAL_ID17, jwot.TERR_QUAL_ID18,
			  jwot.TERR_QUAL_ID19, jwot.TERR_QUAL_ID20, jwot.TERR_QUAL_ID21,
			  jwot.TERR_QUAL_ID22, jwot.TERR_QUAL_ID23,jwot.TERR_QUAL_ID24,
			  jwot.TERR_QUAL_ID25, jwot.TERR_QUAL_ID26, jwot.TERR_QUAL_ID27,
			  jwot.TERR_QUAL_ID28, jwot.TERR_QUAL_ID29,
			  jwot.TERR_QUAL_ID30, jwot.TERR_QUAL_ID31,
			  jwot.TERR_QUAL_ID32, jwot.TERR_QUAL_ID33,jwot.TERR_QUAL_ID34,
			  jwot.TERR_QUAL_ID35, jwot.TERR_QUAL_ID36, jwot.TERR_QUAL_ID37,
			  jwot.TERR_QUAL_ID38, jwot.TERR_QUAL_ID39,
			  jwot.TERR_QUAL_ID40, jwot.TERR_QUAL_ID41,
			  jwot.TERR_QUAL_ID42, jwot.TERR_QUAL_ID43,jwot.TERR_QUAL_ID44,
			  jwot.TERR_QUAL_ID45, jwot.TERR_QUAL_ID46, jwot.TERR_QUAL_ID47,
			  jwot.TERR_QUAL_ID48, jwot.TERR_QUAL_ID49,
			  jwot.TERR_QUAL_ID50, jwot.TERR_QUAL_ID51,
			  jwot.TERR_QUAL_ID52, jwot.TERR_QUAL_ID53,jwot.TERR_QUAL_ID54,
			  jwot.TERR_QUAL_ID55, jwot.TERR_QUAL_ID56, jwot.TERR_QUAL_ID57,
			  jwot.TERR_QUAL_ID58, jwot.TERR_QUAL_ID59,
			  jwot.TERR_QUAL_ID60, jwot.TERR_QUAL_ID61,
			  jwot.TERR_QUAL_ID62, jwot.TERR_QUAL_ID63,jwot.TERR_QUAL_ID64,
			  jwot.TERR_QUAL_ID65, jwot.TERR_QUAL_ID66, jwot.TERR_QUAL_ID67,
			  jwot.TERR_QUAL_ID68, jwot.TERR_QUAL_ID69,
			  jwot.TERR_QUAL_ID70, jwot.TERR_QUAL_ID71,
			  jwot.TERR_QUAL_ID72, jwot.TERR_QUAL_ID73,jwot.TERR_QUAL_ID74,
			  jwot.TERR_QUAL_ID75
			  )
		AND interface_type = l_intf_type
		and header = l_header
		and user_sequence = p_user_sequence;
	end if;

  end if; -- terr_id count
  l_action_flag := 'U';
  debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_QUAL  : Inside and  Action Update' );
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  open get_qual_csr(P_USER_SEQUENCE, l_action_flag, l_intf_type, l_header);
  fetch get_qual_csr bulk collect into
	l_Terr_Qual_Rec.TERR_QUAL_ID, l_Terr_Qual_Rec.terr_id,
	l_Terr_Qual_Rec.qual_value_id, l_Terr_Qual_Rec.qual_value1,
	l_Terr_Qual_Rec.qual_value2, l_Terr_Qual_Rec.qual_value3,
  	l_Terr_Qual_Rec.org_id, l_Terr_Qual_Rec.last_updated_by,
	l_Terr_Qual_Rec.last_update_date, l_Terr_Qual_Rec.last_update_login,
	l_Terr_Qual_Rec.creation_date, l_Terr_Qual_Rec.created_by,
  	l_Terr_Qual_Rec.qual_usg_id, l_Terr_Qual_Rec.qual_type,
	l_Terr_Qual_Rec.CONVERT_TO_ID_FLAG, l_Terr_Qual_Rec.qualifier_num,
	l_Terr_Qual_Rec.html_lov_sql1, l_Terr_Qual_Rec.qual_cond;
  close get_qual_csr;
   debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_QUAL  : Action Update : l_Terr_Qual_Rec.TERR_ID.count ' || l_Terr_Qual_Rec.TERR_ID.count );
  if (l_action_flag = 'U' AND l_Terr_Qual_Rec.TERR_ID.count > 0) then

    INSERT_TERR_QUAL (
      p_Terr_Qual_Rec	=> l_Terr_Qual_Rec,
   	  x_return_status	=> x_return_status,
      x_msg_data		=> x_msg_data);

    if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
      INSERT_TERR_VALUES(
     	p_Terr_Qual_Rec	  	  => l_terr_qual_rec,
     	p_terr_values_out_rec => l_terr_values_out_rec,
     	x_return_status		  => x_return_status,
     	x_msg_data			  => x_msg_data);
    end if;

    forall i in l_Terr_Qual_Rec.TERR_ID.first..l_Terr_Qual_Rec.TERR_ID.last
	  UPDATE JTY_WEBADI_OTH_TERR_INTF jwot
	  set
	  jwot.terr_qual_id1 = decode(l_Terr_Qual_Rec.qualifier_num(i),1,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id1),
	  jwot.terr_qual_id2 = decode(l_Terr_Qual_Rec.qualifier_num(i),2,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id2),
	  jwot.terr_qual_id3 = decode(l_Terr_Qual_Rec.qualifier_num(i),3,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id3),
	  jwot.terr_qual_id4 = decode(l_Terr_Qual_Rec.qualifier_num(i),4,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id4),
	  jwot.terr_qual_id5 = decode(l_Terr_Qual_Rec.qualifier_num(i),5,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id5),
	  jwot.terr_qual_id6 = decode(l_Terr_Qual_Rec.qualifier_num(i),6,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id6),
	  jwot.terr_qual_id7 = decode(l_Terr_Qual_Rec.qualifier_num(i),7,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id7),
	  jwot.terr_qual_id8 = decode(l_Terr_Qual_Rec.qualifier_num(i),8,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id8),
	  jwot.terr_qual_id9 = decode(l_Terr_Qual_Rec.qualifier_num(i),9,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id9),
	  jwot.terr_qual_id10 = decode(l_Terr_Qual_Rec.qualifier_num(i),10,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id10),
	  jwot.terr_qual_id11 = decode(l_Terr_Qual_Rec.qualifier_num(i),11,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id11),
	  jwot.terr_qual_id12 = decode(l_Terr_Qual_Rec.qualifier_num(i),12,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id12),
	  jwot.terr_qual_id13 = decode(l_Terr_Qual_Rec.qualifier_num(i),13,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id13),
	  jwot.terr_qual_id14 = decode(l_Terr_Qual_Rec.qualifier_num(i),14,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id14),
	  jwot.terr_qual_id15 = decode(l_Terr_Qual_Rec.qualifier_num(i),15,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id15),
	  jwot.terr_qual_id16 = decode(l_Terr_Qual_Rec.qualifier_num(i),16,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id16),
	  jwot.terr_qual_id17 = decode(l_Terr_Qual_Rec.qualifier_num(i),17,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id17),
	  jwot.terr_qual_id18 = decode(l_Terr_Qual_Rec.qualifier_num(i),18,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id18),
	  jwot.terr_qual_id19 = decode(l_Terr_Qual_Rec.qualifier_num(i),19,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id19),
	  jwot.terr_qual_id20 = decode(l_Terr_Qual_Rec.qualifier_num(i),20,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id20),
	  jwot.terr_qual_id21 = decode(l_Terr_Qual_Rec.qualifier_num(i),21,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id21),
	  jwot.terr_qual_id22 = decode(l_Terr_Qual_Rec.qualifier_num(i),22,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id22),
	  jwot.terr_qual_id23 = decode(l_Terr_Qual_Rec.qualifier_num(i),23,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id23),
	  jwot.terr_qual_id24 = decode(l_Terr_Qual_Rec.qualifier_num(i),24,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id24),
	  jwot.terr_qual_id25 = decode(l_Terr_Qual_Rec.qualifier_num(i),25,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id25),
	  jwot.terr_qual_id26 = decode(l_Terr_Qual_Rec.qualifier_num(i),26,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id26),
	  jwot.terr_qual_id27 = decode(l_Terr_Qual_Rec.qualifier_num(i),27,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id27),
	  jwot.terr_qual_id28 = decode(l_Terr_Qual_Rec.qualifier_num(i),28,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id28),
	  jwot.terr_qual_id29 = decode(l_Terr_Qual_Rec.qualifier_num(i),29,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id29),
	  jwot.terr_qual_id30 = decode(l_Terr_Qual_Rec.qualifier_num(i),30,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id30),
	  jwot.terr_qual_id31 = decode(l_Terr_Qual_Rec.qualifier_num(i),31,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id31),
	  jwot.terr_qual_id32 = decode(l_Terr_Qual_Rec.qualifier_num(i),32,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id32),
	  jwot.terr_qual_id33 = decode(l_Terr_Qual_Rec.qualifier_num(i),33,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id33),
	  jwot.terr_qual_id34 = decode(l_Terr_Qual_Rec.qualifier_num(i),34,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id34),
	  jwot.terr_qual_id35 = decode(l_Terr_Qual_Rec.qualifier_num(i),35,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id35),
	  jwot.terr_qual_id36 = decode(l_Terr_Qual_Rec.qualifier_num(i),36,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id36),
	  jwot.terr_qual_id37 = decode(l_Terr_Qual_Rec.qualifier_num(i),37,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id37),
	  jwot.terr_qual_id38 = decode(l_Terr_Qual_Rec.qualifier_num(i),38,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id38),
	  jwot.terr_qual_id39 = decode(l_Terr_Qual_Rec.qualifier_num(i),39,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id39),
	  jwot.terr_qual_id40 = decode(l_Terr_Qual_Rec.qualifier_num(i),40,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id40),
	  jwot.terr_qual_id41 = decode(l_Terr_Qual_Rec.qualifier_num(i),41,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id41),
	  jwot.terr_qual_id42 = decode(l_Terr_Qual_Rec.qualifier_num(i),42,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id42),
	  jwot.terr_qual_id43 = decode(l_Terr_Qual_Rec.qualifier_num(i),43,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id43),
	  jwot.terr_qual_id44 = decode(l_Terr_Qual_Rec.qualifier_num(i),44,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id44),
	  jwot.terr_qual_id45 = decode(l_Terr_Qual_Rec.qualifier_num(i),45,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id45),
	  jwot.terr_qual_id46 = decode(l_Terr_Qual_Rec.qualifier_num(i),46,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id46),
	  jwot.terr_qual_id47 = decode(l_Terr_Qual_Rec.qualifier_num(i),47,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id47),
	  jwot.terr_qual_id48 = decode(l_Terr_Qual_Rec.qualifier_num(i),48,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id48),
	  jwot.terr_qual_id49 = decode(l_Terr_Qual_Rec.qualifier_num(i),49,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id49),
	  jwot.terr_qual_id50 = decode(l_Terr_Qual_Rec.qualifier_num(i),50,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id50),
	  jwot.terr_qual_id51 = decode(l_Terr_Qual_Rec.qualifier_num(i),51,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id51),
	  jwot.terr_qual_id52 = decode(l_Terr_Qual_Rec.qualifier_num(i),52,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id52),
	  jwot.terr_qual_id53 = decode(l_Terr_Qual_Rec.qualifier_num(i),53,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id53),
	  jwot.terr_qual_id54 = decode(l_Terr_Qual_Rec.qualifier_num(i),54,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id54),
	  jwot.terr_qual_id55 = decode(l_Terr_Qual_Rec.qualifier_num(i),55,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id55),
	  jwot.terr_qual_id56 = decode(l_Terr_Qual_Rec.qualifier_num(i),56,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id56),
	  jwot.terr_qual_id57 = decode(l_Terr_Qual_Rec.qualifier_num(i),57,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id57),
	  jwot.terr_qual_id58 = decode(l_Terr_Qual_Rec.qualifier_num(i),58,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id58),
	  jwot.terr_qual_id59 = decode(l_Terr_Qual_Rec.qualifier_num(i),59,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id59),
	  jwot.terr_qual_id60 = decode(l_Terr_Qual_Rec.qualifier_num(i),60,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id60),
	  jwot.terr_qual_id61 = decode(l_Terr_Qual_Rec.qualifier_num(i),61,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id61),
	  jwot.terr_qual_id62 = decode(l_Terr_Qual_Rec.qualifier_num(i),62,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id62),
	  jwot.terr_qual_id63 = decode(l_Terr_Qual_Rec.qualifier_num(i),63,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id63),
	  jwot.terr_qual_id64 = decode(l_Terr_Qual_Rec.qualifier_num(i),64,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id64),
	  jwot.terr_qual_id65 = decode(l_Terr_Qual_Rec.qualifier_num(i),65,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id65),
	  jwot.terr_qual_id66 = decode(l_Terr_Qual_Rec.qualifier_num(i),66,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id66),
	  jwot.terr_qual_id67 = decode(l_Terr_Qual_Rec.qualifier_num(i),67,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id67),
	  jwot.terr_qual_id68 = decode(l_Terr_Qual_Rec.qualifier_num(i),68,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id68),
	  jwot.terr_qual_id69 = decode(l_Terr_Qual_Rec.qualifier_num(i),69,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id69),
	  jwot.terr_qual_id70 = decode(l_Terr_Qual_Rec.qualifier_num(i),70,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id70),
	  jwot.terr_qual_id71 = decode(l_Terr_Qual_Rec.qualifier_num(i),71,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id71),
	  jwot.terr_qual_id72 = decode(l_Terr_Qual_Rec.qualifier_num(i),72,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id72),
	  jwot.terr_qual_id73 = decode(l_Terr_Qual_Rec.qualifier_num(i),73,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id73),
	  jwot.terr_qual_id74 = decode(l_Terr_Qual_Rec.qualifier_num(i),74,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id74),
	  jwot.terr_qual_id75 = decode(l_Terr_Qual_Rec.qualifier_num(i),75,l_Terr_Qual_Rec.TERR_QUAL_ID(i),jwot.terr_qual_id75)
	  where TERR_ID = l_Terr_Qual_Rec.TERR_ID(i)
	    and user_sequence = p_user_sequence
		and header = l_header
		and interface_type = l_intf_type;

	if x_return_status = FND_API.G_RET_STS_ERROR then
    forall i in l_Terr_Qual_Rec.TERR_QUAL_ID.first..l_Terr_Qual_Rec.TERR_QUAL_ID.last
	  UPDATE JTY_WEBADI_OTH_TERR_INTF jwot
	  SET STATUS = 	x_return_status,
	  ERROR_MSG = x_msg_data
	  WHERE l_Terr_Qual_Rec.TERR_QUAL_ID(i) in
	  		( jwot.TERR_QUAL_ID1, jwot.TERR_QUAL_ID2, jwot.TERR_QUAL_ID3,
			  jwot.TERR_QUAL_ID4, jwot.TERR_QUAL_ID5, jwot.TERR_QUAL_ID6,
			  jwot.TERR_QUAL_ID7, jwot.TERR_QUAL_ID8, jwot.TERR_QUAL_ID9,
			  jwot.TERR_QUAL_ID10, jwot.TERR_QUAL_ID11, jwot.TERR_QUAL_ID12,
			  jwot.TERR_QUAL_ID13, jwot.TERR_QUAL_ID14, jwot.TERR_QUAL_ID15,
			  jwot.TERR_QUAL_ID16, jwot.TERR_QUAL_ID17, jwot.TERR_QUAL_ID18,
			  jwot.TERR_QUAL_ID19, jwot.TERR_QUAL_ID20, jwot.TERR_QUAL_ID21,
			  jwot.TERR_QUAL_ID22, jwot.TERR_QUAL_ID23,
			  jwot.TERR_QUAL_ID24, jwot.TERR_QUAL_ID25, jwot.TERR_QUAL_ID26, jwot.TERR_QUAL_ID27,
			  jwot.TERR_QUAL_ID28, jwot.TERR_QUAL_ID29,
			  jwot.TERR_QUAL_ID30, jwot.TERR_QUAL_ID31,
			  jwot.TERR_QUAL_ID32, jwot.TERR_QUAL_ID33,jwot.TERR_QUAL_ID34,
			  jwot.TERR_QUAL_ID35, jwot.TERR_QUAL_ID36, jwot.TERR_QUAL_ID37,
			  jwot.TERR_QUAL_ID38, jwot.TERR_QUAL_ID39,
			  jwot.TERR_QUAL_ID40, jwot.TERR_QUAL_ID41,
			  jwot.TERR_QUAL_ID42, jwot.TERR_QUAL_ID43,jwot.TERR_QUAL_ID44,
			  jwot.TERR_QUAL_ID45, jwot.TERR_QUAL_ID46, jwot.TERR_QUAL_ID47,
			  jwot.TERR_QUAL_ID48, jwot.TERR_QUAL_ID49,
			  jwot.TERR_QUAL_ID50, jwot.TERR_QUAL_ID51,
			  jwot.TERR_QUAL_ID52, jwot.TERR_QUAL_ID53,jwot.TERR_QUAL_ID54,
			  jwot.TERR_QUAL_ID55, jwot.TERR_QUAL_ID56, jwot.TERR_QUAL_ID57,
			  jwot.TERR_QUAL_ID58, jwot.TERR_QUAL_ID59,
			  jwot.TERR_QUAL_ID60, jwot.TERR_QUAL_ID61,
			  jwot.TERR_QUAL_ID62, jwot.TERR_QUAL_ID63,jwot.TERR_QUAL_ID64,
			  jwot.TERR_QUAL_ID65, jwot.TERR_QUAL_ID66, jwot.TERR_QUAL_ID67,
			  jwot.TERR_QUAL_ID68, jwot.TERR_QUAL_ID69,
			  jwot.TERR_QUAL_ID70, jwot.TERR_QUAL_ID71,
			  jwot.TERR_QUAL_ID72, jwot.TERR_QUAL_ID73,jwot.TERR_QUAL_ID74,
			  jwot.TERR_QUAL_ID75	)
		AND interface_type = l_intf_type
		and header = l_header
		and user_sequence = p_user_sequence;
	end if;
  end if; -- terr_id count

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_QUAL  : get_c_terr_value_csr before' );
  debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_QUAL  : get_c_terr_value_csr l_action_flag ' || l_action_flag);
  open get_c_terr_value_csr(P_USER_SEQUENCE, l_intf_type, l_header);
  fetch get_c_terr_value_csr bulk collect into
	l_Terr_Qual_Rec.TERR_QUAL_ID, l_Terr_Qual_Rec.terr_id,
	l_Terr_Qual_Rec.qual_value_id, l_Terr_Qual_Rec.qual_value1,
	l_Terr_Qual_Rec.qual_value2, l_Terr_Qual_Rec.qual_value3,
  	l_Terr_Qual_Rec.org_id, l_Terr_Qual_Rec.last_updated_by,
	l_Terr_Qual_Rec.last_update_date, l_Terr_Qual_Rec.last_update_login,
	l_Terr_Qual_Rec.creation_date, l_Terr_Qual_Rec.created_by,
  	l_Terr_Qual_Rec.qual_usg_id, l_Terr_Qual_Rec.qual_type,
	l_Terr_Qual_Rec.CONVERT_TO_ID_FLAG, l_Terr_Qual_Rec.qualifier_num,
	l_Terr_Qual_Rec.html_lov_sql1, l_Terr_Qual_Rec.qual_cond;
  close get_c_terr_value_csr;

  debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_QUAL get_c_terr_value_csr : l_Terr_Qual_Rec.TERR_QUAL_ID.count ' || l_Terr_Qual_Rec.TERR_QUAL_ID.count);
  if (l_Terr_Qual_Rec.TERR_QUAL_ID.count > 0) then
    INSERT_TERR_VALUES(
	p_Terr_Qual_Rec	=> l_terr_qual_rec,
	p_terr_values_out_rec => l_terr_values_out_rec,
	x_return_status		  => x_return_status,
	x_msg_data			  => x_msg_data);
        debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_QUAL  : get_c_terr_value_csr after : INSERT_TERR_VALUES : x_return_status ' || x_return_status );
	if x_return_status = FND_API.G_RET_STS_ERROR then
	forall i in l_Terr_Qual_Rec.TERR_QUAL_ID.first..l_Terr_Qual_Rec.TERR_QUAL_ID.last
	  UPDATE JTY_WEBADI_OTH_TERR_INTF jwot
	  SET STATUS = 	x_return_status,
	  ERROR_MSG = x_msg_data
	  WHERE l_Terr_Qual_Rec.TERR_QUAL_ID(i) in
	  		( jwot.TERR_QUAL_ID1, jwot.TERR_QUAL_ID2, jwot.TERR_QUAL_ID3,
			  jwot.TERR_QUAL_ID4, jwot.TERR_QUAL_ID5, jwot.TERR_QUAL_ID6,
			  jwot.TERR_QUAL_ID7, jwot.TERR_QUAL_ID8, jwot.TERR_QUAL_ID9,
			  jwot.TERR_QUAL_ID10, jwot.TERR_QUAL_ID11, jwot.TERR_QUAL_ID12,
			  jwot.TERR_QUAL_ID13, jwot.TERR_QUAL_ID14, jwot.TERR_QUAL_ID15,
			  jwot.TERR_QUAL_ID16, jwot.TERR_QUAL_ID17, jwot.TERR_QUAL_ID18,
			  jwot.TERR_QUAL_ID19, jwot.TERR_QUAL_ID20, jwot.TERR_QUAL_ID21,
			  jwot.TERR_QUAL_ID22, jwot.TERR_QUAL_ID23,
			  jwot.TERR_QUAL_ID24, jwot.TERR_QUAL_ID25, jwot.TERR_QUAL_ID26, jwot.TERR_QUAL_ID27,
			  jwot.TERR_QUAL_ID28, jwot.TERR_QUAL_ID29,
			  jwot.TERR_QUAL_ID30, jwot.TERR_QUAL_ID31,
			  jwot.TERR_QUAL_ID32, jwot.TERR_QUAL_ID33,jwot.TERR_QUAL_ID34,
			  jwot.TERR_QUAL_ID35, jwot.TERR_QUAL_ID36, jwot.TERR_QUAL_ID37,
			  jwot.TERR_QUAL_ID38, jwot.TERR_QUAL_ID39,
			  jwot.TERR_QUAL_ID40, jwot.TERR_QUAL_ID41,
			  jwot.TERR_QUAL_ID42, jwot.TERR_QUAL_ID43,jwot.TERR_QUAL_ID44,
			  jwot.TERR_QUAL_ID45, jwot.TERR_QUAL_ID46, jwot.TERR_QUAL_ID47,
			  jwot.TERR_QUAL_ID48, jwot.TERR_QUAL_ID49,
			  jwot.TERR_QUAL_ID50, jwot.TERR_QUAL_ID51,
			  jwot.TERR_QUAL_ID52, jwot.TERR_QUAL_ID53,jwot.TERR_QUAL_ID54,
			  jwot.TERR_QUAL_ID55, jwot.TERR_QUAL_ID56, jwot.TERR_QUAL_ID57,
			  jwot.TERR_QUAL_ID58, jwot.TERR_QUAL_ID59,
			  jwot.TERR_QUAL_ID60, jwot.TERR_QUAL_ID61,
			  jwot.TERR_QUAL_ID62, jwot.TERR_QUAL_ID63,jwot.TERR_QUAL_ID64,
			  jwot.TERR_QUAL_ID65, jwot.TERR_QUAL_ID66, jwot.TERR_QUAL_ID67,
			  jwot.TERR_QUAL_ID68, jwot.TERR_QUAL_ID69,
			  jwot.TERR_QUAL_ID70, jwot.TERR_QUAL_ID71,
			  jwot.TERR_QUAL_ID72, jwot.TERR_QUAL_ID73,jwot.TERR_QUAL_ID74,
			  jwot.TERR_QUAL_ID75	)
		AND interface_type = l_intf_type
		and header = l_header
		and user_sequence = p_user_sequence;
	end if;
  end if; --get_c_terr_value_csr
    debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_QUAL  : get_u_terr_value_csr before' );
    debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_QUAL  : get_u_terr_value_csr l_action_flag ' || l_action_flag);
  open get_u_terr_value_csr(P_USER_SEQUENCE, l_action_flag, l_intf_type, l_header);
  fetch get_u_terr_value_csr bulk collect into
	l_Terr_Qual_Rec.TERR_QUAL_ID, l_Terr_Qual_Rec.terr_id,
	l_Terr_Qual_Rec.qual_value_id, l_Terr_Qual_Rec.qual_value1,
	l_Terr_Qual_Rec.qual_value2, l_Terr_Qual_Rec.qual_value3,
  	l_Terr_Qual_Rec.org_id, l_Terr_Qual_Rec.last_updated_by,
	l_Terr_Qual_Rec.last_update_date, l_Terr_Qual_Rec.last_update_login,
	l_Terr_Qual_Rec.creation_date, l_Terr_Qual_Rec.created_by,
  	l_Terr_Qual_Rec.qual_usg_id, l_Terr_Qual_Rec.qual_type,
	l_Terr_Qual_Rec.CONVERT_TO_ID_FLAG, l_Terr_Qual_Rec.qualifier_num,
	l_Terr_Qual_Rec.html_lov_sql1, l_Terr_Qual_Rec.qual_cond;
  close get_u_terr_value_csr;
   debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_QUAL get_u_terr_value_csr : l_Terr_Qual_Rec.TERR_QUAL_ID.count ' || l_Terr_Qual_Rec.TERR_QUAL_ID.count);
  if (l_Terr_Qual_Rec.TERR_QUAL_ID.count > 0) then
  BEGIN
    --dbms_output.put_line('U: get_u_terr_value_csr: update TV, rowcount: ' || l_Terr_Qual_Rec.TERR_QUAL_ID.count);

	x_return_status := FND_API.G_RET_STS_SUCCESS;
    for i in l_Terr_Qual_Rec.TERR_QUAL_ID.first..l_Terr_Qual_Rec.TERR_QUAL_ID.last loop

	   l_Terr_Values_Rec.LAST_UPDATE_DATE(i)  := l_Terr_Qual_Rec.LAST_UPDATE_DATE(i);
	   l_Terr_Values_Rec.LAST_UPDATED_BY(i)   := l_Terr_Qual_Rec.LAST_UPDATED_BY(i);
	   l_Terr_Values_Rec.CREATION_DATE(i) 	  := l_Terr_Qual_Rec.CREATION_DATE(i);
	   l_Terr_Values_Rec.CREATED_BY(i)    	  := l_Terr_Qual_Rec.CREATED_BY(i);
	   l_Terr_Values_Rec.LAST_UPDATE_LOGIN(i) := l_Terr_Qual_Rec.LAST_UPDATE_LOGIN(i);
	   l_Terr_Values_Rec.TERR_QUAL_ID(i)  	  := l_Terr_Qual_Rec.TERR_QUAL_ID(i);
	   l_Terr_Values_Rec.COMPARISON_OPERATOR(i) := l_Terr_Qual_Rec.qual_cond(i);
       l_Terr_Values_Rec.ID_USED_FLAG(i)        := l_Terr_Qual_Rec.CONVERT_TO_ID_FLAG(i);
	   l_Terr_Values_Rec.ORG_ID(i)              := l_Terr_Qual_Rec.ORG_ID(i);
	   l_Terr_Values_Rec.TERR_VALUE_ID(i) := l_Terr_Qual_Rec.qual_value_id(i);
        l_Terr_Values_Rec.LOW_VALUE_CHAR(i):= NULL;
        l_Terr_Values_Rec.HIGH_VALUE_CHAR(i):= NULL;
        l_Terr_Values_Rec.LOW_VALUE_NUMBER(i):= NULL;
        l_Terr_Values_Rec.HIGH_VALUE_NUMBER(i):= NULL;
        l_Terr_Values_Rec.INTEREST_TYPE_ID(i):= NULL;
        l_Terr_Values_Rec.PRIMARY_INTEREST_CODE_ID(i):= NULL;
        l_Terr_Values_Rec.SECONDARY_INTEREST_CODE_ID(i):= NULL;
        l_Terr_Values_Rec.CURRENCY_CODE(i):= NULL;
        --l_Terr_Values_Rec.ID_USED_FLAG(i):= NULL;
        l_Terr_Values_Rec.LOW_VALUE_CHAR_ID(i):= NULL;
        --l_Terr_Values_Rec.ORG_ID(i):= NULL;
        l_Terr_Values_Rec.VALUE1_ID(i):= NULL;
        l_Terr_Values_Rec.VALUE2_ID(i):= NULL;
        l_Terr_Values_Rec.VALUE3_ID(i):= NULL;
	    case
	     when l_Terr_Qual_Rec.qual_type(i) = 'CHAR' then
		   IF l_Terr_Qual_Rec.CONVERT_TO_ID_FLAG(i) = 'N' then
		     l_Terr_Values_Rec.LOW_VALUE_CHAR(i) := l_Terr_Qual_Rec.qual_value1(i);
			 if l_Terr_Qual_Rec.qual_value2.count > 0 then
		       l_Terr_Values_Rec.HIGH_VALUE_CHAR(i) := l_Terr_Qual_Rec.qual_value2(i);
			 else l_Terr_Values_Rec.HIGH_VALUE_CHAR(i) := NULL;
			 end if;
		   else
		     l_Terr_Values_Rec.LOW_VALUE_CHAR_ID(i) := l_Terr_Qual_Rec.qual_value1(i);
		   end if;
         when l_Terr_Qual_Rec.qual_type(i) = 'DEP_2FIELDS_1CHAR_1ID' then
		   l_Terr_Values_Rec.LOW_VALUE_CHAR(i) := l_Terr_Qual_Rec.qual_value1(i);
		   if l_Terr_Qual_Rec.qual_value2.count > 0 then
		     l_Terr_Values_Rec.LOW_VALUE_CHAR_ID(i) := l_Terr_Qual_Rec.qual_value2(i);
		   else l_Terr_Values_Rec.LOW_VALUE_CHAR_ID(i) := NULL;
		   end if;
         when l_Terr_Qual_Rec.qual_type(i) in
           ('CHAR_2IDS', 'DEP_2FIELDS', 'DEP_2FIELDS_CHAR_2IDS') then
		   l_Terr_Values_Rec.VALUE1_ID(i) := l_Terr_Qual_Rec.qual_value1(i);
		   if l_Terr_Qual_Rec.qual_value2.count > 0 then
		     l_Terr_Values_Rec.VALUE2_ID(i) := l_Terr_Qual_Rec.qual_value2(i);
		   else l_Terr_Values_Rec.VALUE2_ID(i) := NULL;
		   end if;
         when l_Terr_Qual_Rec.qual_type(i) = 'DEP_3FIELDS_CHAR_3IDS' then
		   l_Terr_Values_Rec.VALUE1_ID(i) := l_Terr_Qual_Rec.qual_value1(i);
		   if l_Terr_Qual_Rec.qual_value2.count > 0 then
		     l_Terr_Values_Rec.VALUE2_ID(i) := l_Terr_Qual_Rec.qual_value2(i);
		   else l_Terr_Values_Rec.VALUE2_ID(i) := NULL;
		   end if;
		   if l_Terr_Qual_Rec.qual_value3.count > 0 then
		     l_Terr_Values_Rec.VALUE3_ID(i) := l_Terr_Qual_Rec.qual_value3(i);
		   else l_Terr_Values_Rec.VALUE3_ID(i) := NULL;
		   end if;
         when l_Terr_Qual_Rec.qual_type(i) = 'INTEREST_TYPE' then
		   l_Terr_Values_Rec.INTEREST_TYPE_ID(i) := l_Terr_Qual_Rec.qual_value1(i);
		   if l_Terr_Qual_Rec.qual_value2.count > 0 then
		     l_Terr_Values_Rec.PRIMARY_INTEREST_CODE_ID(i) := l_Terr_Qual_Rec.qual_value2(i);
		   else l_Terr_Values_Rec.PRIMARY_INTEREST_CODE_ID(i) := NULL;
		   end if;
		   if l_Terr_Qual_Rec.qual_value3.count > 0 then
		     l_Terr_Values_Rec.SECONDARY_INTEREST_CODE_ID(i) := l_Terr_Qual_Rec.qual_value3(i);
		   else l_Terr_Values_Rec.SECONDARY_INTEREST_CODE_ID(i) := NULL;
		   end if;
         when l_Terr_Qual_Rec.qual_type(i) = 'NUMERIC' then
		   l_Terr_Values_Rec.LOW_VALUE_NUMBER(i) := l_Terr_Qual_Rec.qual_value1(i);
		   if l_Terr_Qual_Rec.qual_value2.count > 0 then
		     l_Terr_Values_Rec.HIGH_VALUE_NUMBER(i) := l_Terr_Qual_Rec.qual_value2(i);
		   else l_Terr_Values_Rec.HIGH_VALUE_NUMBER(i) := NULL;
		   end if;
         when l_Terr_Qual_Rec.qual_type(i) = 'CURRENCY' then
		   l_Terr_Values_Rec.LOW_VALUE_NUMBER(i) := l_Terr_Qual_Rec.qual_value1(i);
		   if l_Terr_Qual_Rec.qual_value2.count > 0 then
		     l_Terr_Values_Rec.HIGH_VALUE_NUMBER(i) := l_Terr_Qual_Rec.qual_value2(i);
		   else l_Terr_Values_Rec.HIGH_VALUE_NUMBER(i) := NULL;
		   end if;
		   if l_Terr_Qual_Rec.qual_value3.count > 0 then
		     l_Terr_Values_Rec.CURRENCY_CODE(i) := l_Terr_Qual_Rec.qual_value3(i);
		   else l_Terr_Values_Rec.CURRENCY_CODE(i) := NULL;
		   end if;
         else null;
	   end case;
	end loop;

        -- Check for duplicate value.
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        Check_duplicate_Value_update(
                p_Terr_Values_Rec => l_Terr_Values_Rec ,
                x_return_status   => x_return_status,
                x_msg_data        => x_msg_data );

        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
          forall i in l_Terr_Values_Rec.TERR_VALUE_ID.first..l_Terr_Values_Rec.TERR_VALUE_ID.last
            Update JTF_TERR_VALUES_ALL
            SET
              LAST_UPDATED_BY = l_Terr_Values_Rec.LAST_UPDATED_BY(i),
              LAST_UPDATE_DATE = l_Terr_Values_Rec.LAST_UPDATE_DATE(i),
              LAST_UPDATE_LOGIN = l_Terr_Values_Rec.LAST_UPDATE_LOGIN(i),
              TERR_QUAL_ID = l_Terr_Values_Rec.TERR_QUAL_ID(i),
              COMPARISON_OPERATOR = l_Terr_Values_Rec.COMPARISON_OPERATOR(i),
              LOW_VALUE_CHAR = l_Terr_Values_Rec.LOW_VALUE_CHAR(i),
              HIGH_VALUE_CHAR = l_Terr_Values_Rec.HIGH_VALUE_CHAR(i),
              LOW_VALUE_NUMBER = l_Terr_Values_Rec.LOW_VALUE_NUMBER(i),
              HIGH_VALUE_NUMBER = l_Terr_Values_Rec.HIGH_VALUE_NUMBER(i),
              INTEREST_TYPE_ID = l_Terr_Values_Rec.INTEREST_TYPE_ID(i),
              PRIMARY_INTEREST_CODE_ID = l_Terr_Values_Rec.PRIMARY_INTEREST_CODE_ID(i),
              SECONDARY_INTEREST_CODE_ID = l_Terr_Values_Rec.SECONDARY_INTEREST_CODE_ID(i),
              CURRENCY_CODE = l_Terr_Values_Rec.CURRENCY_CODE(i),
              ID_USED_FLAG = l_Terr_Values_Rec.ID_USED_FLAG(i),
              LOW_VALUE_CHAR_ID = l_Terr_Values_Rec.LOW_VALUE_CHAR_ID(i),
              ORG_ID = l_Terr_Values_Rec.ORG_ID(i),
              VALUE1_ID = l_Terr_Values_Rec.VALUE1_ID(i),
              VALUE2_ID = l_Terr_Values_Rec.VALUE2_ID(i),
              VALUE3_ID = l_Terr_Values_Rec.VALUE3_ID(i)
            where TERR_VALUE_ID = l_Terr_Values_Rec.TERR_VALUE_ID(i);

          debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_QUAL  : U: get_u_terr_value_csr:TV, actual row processed:  '||SQL%ROWCOUNT );
        END IF;

	--dbms_output.put_line(' U: get_u_terr_value_csr:TV, actual row processed:  '||SQL%ROWCOUNT);

	EXCEPTION
	  WHEN OTHERS THEN
	  debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_QUAL  : Inside exception others');
        x_return_status := FND_API.G_RET_STS_ERROR;
		fnd_message.clear;
        fnd_message.set_name ('JTF', 'JTY_OTH_TERR_UPDATE_QUAL_VAL');
        X_Msg_Data := fnd_message.get();

    	forall i in l_Terr_Qual_Rec.TERR_QUAL_ID.first..l_Terr_Qual_Rec.TERR_QUAL_ID.last
    	  UPDATE JTY_WEBADI_OTH_TERR_INTF jwot
    	  SET STATUS = x_return_status,
		  error_msg = 'U: ' || x_msg_data
    	  WHERE l_Terr_Qual_Rec.TERR_QUAL_ID(i) in
    	  		( jwot.TERR_QUAL_ID1, jwot.TERR_QUAL_ID2, jwot.TERR_QUAL_ID3,
    			  jwot.TERR_QUAL_ID4, jwot.TERR_QUAL_ID5, jwot.TERR_QUAL_ID6,
    			  jwot.TERR_QUAL_ID7, jwot.TERR_QUAL_ID8, jwot.TERR_QUAL_ID9,
    			  jwot.TERR_QUAL_ID10, jwot.TERR_QUAL_ID11, jwot.TERR_QUAL_ID12,
    			  jwot.TERR_QUAL_ID13, jwot.TERR_QUAL_ID14, jwot.TERR_QUAL_ID15,
    			  jwot.TERR_QUAL_ID16, jwot.TERR_QUAL_ID17, jwot.TERR_QUAL_ID18,
    			  jwot.TERR_QUAL_ID19, jwot.TERR_QUAL_ID20, jwot.TERR_QUAL_ID21,
    			  jwot.TERR_QUAL_ID22, jwot.TERR_QUAL_ID23,
    			  jwot.TERR_QUAL_ID24, jwot.TERR_QUAL_ID25, jwot.TERR_QUAL_ID26, jwot.TERR_QUAL_ID27,
				  jwot.TERR_QUAL_ID28, jwot.TERR_QUAL_ID29,
				  jwot.TERR_QUAL_ID30, jwot.TERR_QUAL_ID31,
				  jwot.TERR_QUAL_ID32, jwot.TERR_QUAL_ID33,jwot.TERR_QUAL_ID34,
				  jwot.TERR_QUAL_ID35, jwot.TERR_QUAL_ID36, jwot.TERR_QUAL_ID37,
				  jwot.TERR_QUAL_ID38, jwot.TERR_QUAL_ID39,
				  jwot.TERR_QUAL_ID40, jwot.TERR_QUAL_ID41,
				  jwot.TERR_QUAL_ID42, jwot.TERR_QUAL_ID43,jwot.TERR_QUAL_ID44,
				  jwot.TERR_QUAL_ID45, jwot.TERR_QUAL_ID46, jwot.TERR_QUAL_ID47,
				  jwot.TERR_QUAL_ID48, jwot.TERR_QUAL_ID49,
				  jwot.TERR_QUAL_ID50, jwot.TERR_QUAL_ID51,
				  jwot.TERR_QUAL_ID52, jwot.TERR_QUAL_ID53,jwot.TERR_QUAL_ID54,
				  jwot.TERR_QUAL_ID55, jwot.TERR_QUAL_ID56, jwot.TERR_QUAL_ID57,
				  jwot.TERR_QUAL_ID58, jwot.TERR_QUAL_ID59,
				  jwot.TERR_QUAL_ID60, jwot.TERR_QUAL_ID61,
				  jwot.TERR_QUAL_ID62, jwot.TERR_QUAL_ID63,jwot.TERR_QUAL_ID64,
				  jwot.TERR_QUAL_ID65, jwot.TERR_QUAL_ID66, jwot.TERR_QUAL_ID67,
				  jwot.TERR_QUAL_ID68, jwot.TERR_QUAL_ID69,
				  jwot.TERR_QUAL_ID70, jwot.TERR_QUAL_ID71,
				  jwot.TERR_QUAL_ID72, jwot.TERR_QUAL_ID73,jwot.TERR_QUAL_ID74,
				  jwot.TERR_QUAL_ID75	)
    		AND interface_type = l_intf_type
    		and header = l_header
    		and action_flag = l_action_flag
    		and user_sequence = p_user_sequence;
	END;
  end if; --get_u_terr_value_csr

  open get_d_terr_value_csr(P_USER_SEQUENCE, l_action_flag, l_intf_type, l_header);
  fetch get_d_terr_value_csr bulk collect into
	l_Terr_Qual_Rec.TERR_QUAL_ID, l_Terr_Qual_Rec.terr_id,
	l_Terr_Qual_Rec.qual_value_id, l_Terr_Qual_Rec.qualifier_num;
  close get_d_terr_value_csr;

  if (l_Terr_Qual_Rec.TERR_QUAL_ID.count > 0) then
  BEGIN
    --dbms_output.put_line('U: get_d_terr_value_csr: delete TV, rowcount: ' || l_Terr_Qual_Rec.TERR_QUAL_ID.count);
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	forall i in l_Terr_Qual_Rec.qual_value_id.first..l_Terr_Qual_Rec.qual_value_id.last
      DELETE FROM JTF_TERR_VALUES_ALL
      where TERR_VALUE_ID = l_Terr_Qual_Rec.qual_value_id(i);
	--dbms_output.put_line(' U: get_d_terr_value_csr:actual row processed:  '||SQL%ROWCOUNT);

	forall i in l_Terr_Qual_Rec.TERR_QUAL_ID.first..l_Terr_Qual_Rec.TERR_QUAL_ID.last
      DELETE FROM JTF_TERR_QUAL_ALL jtq
	  WHERE not exists
	  ( select 1 from JTF_TERR_VALUES_ALL jtv
	    where jtv.terr_qual_id = jtq.terr_qual_id)
	  and jtq.terr_qual_id = l_Terr_Qual_Rec.TERR_QUAL_ID(i);
	--dbms_output.put_line(' U: get_d_terr_value_csr:TV, actual row processed:  '||SQL%ROWCOUNT);

	forall i in l_Terr_Qual_Rec.TERR_QUAL_ID.first..l_Terr_Qual_Rec.TERR_QUAL_ID.last
	  UPDATE JTY_WEBADI_OTH_TERR_INTF jwot
	  SET STATUS = 	x_return_status
	  WHERE l_Terr_Qual_Rec.TERR_QUAL_ID(i) in
	  		( jwot.TERR_QUAL_ID1, jwot.TERR_QUAL_ID2, jwot.TERR_QUAL_ID3,
			  jwot.TERR_QUAL_ID4, jwot.TERR_QUAL_ID5, jwot.TERR_QUAL_ID6,
			  jwot.TERR_QUAL_ID7, jwot.TERR_QUAL_ID8, jwot.TERR_QUAL_ID9,
			  jwot.TERR_QUAL_ID10, jwot.TERR_QUAL_ID11, jwot.TERR_QUAL_ID12,
			  jwot.TERR_QUAL_ID13, jwot.TERR_QUAL_ID14, jwot.TERR_QUAL_ID15,
			  jwot.TERR_QUAL_ID16, jwot.TERR_QUAL_ID17, jwot.TERR_QUAL_ID18,
			  jwot.TERR_QUAL_ID19, jwot.TERR_QUAL_ID20, jwot.TERR_QUAL_ID21,
			  jwot.TERR_QUAL_ID22, jwot.TERR_QUAL_ID23,
			  jwot.TERR_QUAL_ID24, jwot.TERR_QUAL_ID25, jwot.TERR_QUAL_ID26, jwot.TERR_QUAL_ID27,
			  jwot.TERR_QUAL_ID28, jwot.TERR_QUAL_ID29,
			  jwot.TERR_QUAL_ID30, jwot.TERR_QUAL_ID31,
			  jwot.TERR_QUAL_ID32, jwot.TERR_QUAL_ID33,jwot.TERR_QUAL_ID34,
			  jwot.TERR_QUAL_ID35, jwot.TERR_QUAL_ID36, jwot.TERR_QUAL_ID37,
			  jwot.TERR_QUAL_ID38, jwot.TERR_QUAL_ID39,
			  jwot.TERR_QUAL_ID40, jwot.TERR_QUAL_ID41,
			  jwot.TERR_QUAL_ID42, jwot.TERR_QUAL_ID43,jwot.TERR_QUAL_ID44,
			  jwot.TERR_QUAL_ID45, jwot.TERR_QUAL_ID46, jwot.TERR_QUAL_ID47,
			  jwot.TERR_QUAL_ID48, jwot.TERR_QUAL_ID49,
			  jwot.TERR_QUAL_ID50, jwot.TERR_QUAL_ID51,
			  jwot.TERR_QUAL_ID52, jwot.TERR_QUAL_ID53,jwot.TERR_QUAL_ID54,
			  jwot.TERR_QUAL_ID55, jwot.TERR_QUAL_ID56, jwot.TERR_QUAL_ID57,
			  jwot.TERR_QUAL_ID58, jwot.TERR_QUAL_ID59,
			  jwot.TERR_QUAL_ID60, jwot.TERR_QUAL_ID61,
			  jwot.TERR_QUAL_ID62, jwot.TERR_QUAL_ID63,jwot.TERR_QUAL_ID64,
			  jwot.TERR_QUAL_ID65, jwot.TERR_QUAL_ID66, jwot.TERR_QUAL_ID67,
			  jwot.TERR_QUAL_ID68, jwot.TERR_QUAL_ID69,
			  jwot.TERR_QUAL_ID70, jwot.TERR_QUAL_ID71,
			  jwot.TERR_QUAL_ID72, jwot.TERR_QUAL_ID73,jwot.TERR_QUAL_ID74,
			  jwot.TERR_QUAL_ID75	)
		AND interface_type = l_intf_type
		and header = l_header
		and action_flag = l_action_flag
		and user_sequence = p_user_sequence;

	EXCEPTION
	  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
		fnd_message.clear;
        fnd_message.set_name ('JTF', 'JTY_OTH_TERR_DELETE_QUAL_VAL');
        X_Msg_Data := fnd_message.get();

    	forall i in l_Terr_Qual_Rec.TERR_QUAL_ID.first..l_Terr_Qual_Rec.TERR_QUAL_ID.last
    	  UPDATE JTY_WEBADI_OTH_TERR_INTF jwot
    	  SET STATUS = x_return_status,
		  error_msg = 'U: ' || x_msg_data
    	  WHERE l_Terr_Qual_Rec.TERR_QUAL_ID(i) in
    	  		( jwot.TERR_QUAL_ID1, jwot.TERR_QUAL_ID2, jwot.TERR_QUAL_ID3,
    			  jwot.TERR_QUAL_ID4, jwot.TERR_QUAL_ID5, jwot.TERR_QUAL_ID6,
    			  jwot.TERR_QUAL_ID7, jwot.TERR_QUAL_ID8, jwot.TERR_QUAL_ID9,
    			  jwot.TERR_QUAL_ID10, jwot.TERR_QUAL_ID11, jwot.TERR_QUAL_ID12,
    			  jwot.TERR_QUAL_ID13, jwot.TERR_QUAL_ID14, jwot.TERR_QUAL_ID15,
    			  jwot.TERR_QUAL_ID16, jwot.TERR_QUAL_ID17, jwot.TERR_QUAL_ID18,
    			  jwot.TERR_QUAL_ID19, jwot.TERR_QUAL_ID20, jwot.TERR_QUAL_ID21,
    			  jwot.TERR_QUAL_ID22, jwot.TERR_QUAL_ID23,
    			  jwot.TERR_QUAL_ID24, jwot.TERR_QUAL_ID25, jwot.TERR_QUAL_ID26, jwot.TERR_QUAL_ID27,
				  jwot.TERR_QUAL_ID28, jwot.TERR_QUAL_ID29,
				  jwot.TERR_QUAL_ID30, jwot.TERR_QUAL_ID31,
				  jwot.TERR_QUAL_ID32, jwot.TERR_QUAL_ID33,jwot.TERR_QUAL_ID34,
				  jwot.TERR_QUAL_ID35, jwot.TERR_QUAL_ID36, jwot.TERR_QUAL_ID37,
				  jwot.TERR_QUAL_ID38, jwot.TERR_QUAL_ID39,
				  jwot.TERR_QUAL_ID40, jwot.TERR_QUAL_ID41,
				  jwot.TERR_QUAL_ID42, jwot.TERR_QUAL_ID43,jwot.TERR_QUAL_ID44,
				  jwot.TERR_QUAL_ID45, jwot.TERR_QUAL_ID46, jwot.TERR_QUAL_ID47,
				  jwot.TERR_QUAL_ID48, jwot.TERR_QUAL_ID49,
				  jwot.TERR_QUAL_ID50, jwot.TERR_QUAL_ID51,
				  jwot.TERR_QUAL_ID52, jwot.TERR_QUAL_ID53,jwot.TERR_QUAL_ID54,
				  jwot.TERR_QUAL_ID55, jwot.TERR_QUAL_ID56, jwot.TERR_QUAL_ID57,
				  jwot.TERR_QUAL_ID58, jwot.TERR_QUAL_ID59,
				  jwot.TERR_QUAL_ID60, jwot.TERR_QUAL_ID61,
				  jwot.TERR_QUAL_ID62, jwot.TERR_QUAL_ID63,jwot.TERR_QUAL_ID64,
				  jwot.TERR_QUAL_ID65, jwot.TERR_QUAL_ID66, jwot.TERR_QUAL_ID67,
				  jwot.TERR_QUAL_ID68, jwot.TERR_QUAL_ID69,
				  jwot.TERR_QUAL_ID70, jwot.TERR_QUAL_ID71,
				  jwot.TERR_QUAL_ID72, jwot.TERR_QUAL_ID73,jwot.TERR_QUAL_ID74,
				  jwot.TERR_QUAL_ID75	)
    		AND interface_type = l_intf_type
    		and header = l_header
    		and action_flag = l_action_flag
    		and user_sequence = p_user_sequence;
	END;
  end if; --get_d_terr_value_csr

  update JTY_WEBADI_OTH_TERR_INTF
  set status = x_return_status
  where interface_type = l_intf_type
    and header = l_header
    and status is null
    and user_sequence = p_user_sequence;

END UPDATE_TERR_QUAL;

PROCEDURE UPDATE_TERR_RSC(
    P_USER_SEQUENCE 	  IN  NUMBER,
	--p_action_flag		  IN VARCHAR2,
	x_return_status		  out nocopy varchar2,
	x_msg_data			  out nocopy varchar2
) IS

  cursor GET_RSC_CSR(
  v_user_sequence	 number,
  v_intf_type		 varchar2,
  v_header			 varchar2,
  v_action_flag		 varchar2) IS
  SELECT jwot.LAY_SEQ_NUM, jwr.TERR_RSC_ID,
    jwot.LAST_UPDATE_DATE, jwot.LAST_UPDATED_BY, jwot.CREATION_DATE,
    jwot.CREATED_BY, jwot.LAST_UPDATE_LOGIN,
    jwot.TERR_ID, jwr.resource_id,
    decode(jwr.resource_type,0, 'RS_'||res.category,
	  --decode(res.category, 'PARTNER', 'RS_PARTNER', 'EMPLOYEE', 'RS_EMPLOYEE',NULL)
	  1,'RS_GROUP',2,'RS_TEAM',3,'RS_ROLE', null) RESOURCE_TYPE,
	jwr.role_code, null PRIMARY_CONTACT_FLAG,
    NVL(jwr.RES_START_DATE, jwot.TERR_START_DATE) START_DATE_ACTIVE,
    NVL(jwr.RES_END_DATE, jwot.TERR_END_DATE) END_DATE_ACTIVE,
    jwot.org_id, 'N' FULL_ACCESS_FLAG,
    jwr.group_id, NULL SECURITY_GROUP_ID,
    res.source_id person_id, NULL OBJECT_VERSION_NUMBER,
    jwr.ATTRIBUTE_CATEGORY, jwr.ATTRIBUTE1, jwr.ATTRIBUTE2,
    jwr.ATTRIBUTE3, jwr.ATTRIBUTE4, jwr.ATTRIBUTE5,
    jwr.ATTRIBUTE6, jwr.ATTRIBUTE7, jwr.ATTRIBUTE8,
    jwr.ATTRIBUTE9, jwr.ATTRIBUTE10, jwr.ATTRIBUTE11,
    jwr.ATTRIBUTE12, jwr.ATTRIBUTE13, jwr.ATTRIBUTE14,
    jwr.ATTRIBUTE15
  from
    JTY_WEBADI_OTH_TERR_INTF jwot,
    JTY_WEBADI_RESOURCES jwr,
    jtf_rs_resource_extns res
  where jwr.RESOURCE_ID = res.resource_id(+)
    and jwr.user_sequence = jwot.user_sequence
    and jwr.interface_type = jwot.interface_type
    and jwot.lay_seq_num = jwr.lay_seq_num
    and jwot.user_sequence = v_user_sequence
    and jwot.interface_type = v_intf_type
    and jwot.header = v_header
    and jwot.status is null
    and jwr.header = jwot.header
    and jwot.action_flag = v_action_flag;

	cursor get_c_rsc_access_csr(
	   v_user_sequence  number,
	   v_header			varchar2,
	   v_intf_type		varchar2) is
	   select sub.TERR_RSC_ACCESS_ID,
       jwot.LAST_UPDATE_DATE, jwot.LAST_UPDATED_BY,
       jwot.CREATION_DATE, jwot.CREATED_BY, jwot.LAST_UPDATE_LOGIN,
       sub.TERR_RSC_ID, jq.QUAL_TYPE_NAME ACCESS_TYPE,
       jwot.ORG_ID, sub.TRANS_ACCESS_CODE
      from JTY_WEBADI_QUAL_TYPE_HEADER jq,
	  JTY_WEBADI_OTH_TERR_INTF jwot,
  	  (
      select user_sequence, TERR_RSC_ID, lay_seq_num, header,
      1 qual_type_num, TERR_RSC_ACCESS_ID1 TERR_RSC_ACCESS_ID,
      TRANS_ACCESS_CODE1 TRANS_ACCESS_CODE
      FROM JTY_WEBADI_RESOURCES jut
      where jut.USER_SEQUENCE = v_user_sequence
      and jut.TRANS_ACCESS_CODE1 is not null
	  and jut.TERR_RSC_ACCESS_ID1 is null
	  and jut.header = v_header
  	  and jut.INTERFACE_TYPE = v_intf_type
      union all
      select user_sequence, TERR_RSC_ID, lay_seq_num, header,
      2 qual_type_num, TERR_RSC_ACCESS_ID2 TERR_RSC_ACCESS_ID,
      TRANS_ACCESS_CODE2 TRANS_ACCESS_CODE
      FROM JTY_WEBADI_RESOURCES jut
      where jut.USER_SEQUENCE = v_user_sequence
      and jut.TRANS_ACCESS_CODE2 is not null
	  and jut.TERR_RSC_ACCESS_ID2 is null
	  and jut.header = v_header
  	  and jut.INTERFACE_TYPE = v_intf_type
      union all
      select user_sequence, TERR_RSC_ID, lay_seq_num, header,
      3 qual_type_num, TERR_RSC_ACCESS_ID3 TERR_RSC_ACCESS_ID,
      TRANS_ACCESS_CODE3 TRANS_ACCESS_CODE
      FROM JTY_WEBADI_RESOURCES jut
      where jut.USER_SEQUENCE = v_user_sequence
      and jut.TRANS_ACCESS_CODE3 is not null
	  and jut.TERR_RSC_ACCESS_ID3 is null
	  and jut.header = v_header
  	  and jut.INTERFACE_TYPE = v_intf_type
      union all
      select user_sequence, TERR_RSC_ID, lay_seq_num, header,
      4 qual_type_num, TERR_RSC_ACCESS_ID4 TERR_RSC_ACCESS_ID,
      TRANS_ACCESS_CODE4 TRANS_ACCESS_CODE
      FROM JTY_WEBADI_RESOURCES jut
      where jut.USER_SEQUENCE = v_user_sequence
      and jut.TRANS_ACCESS_CODE4 is not null
	  and jut.TERR_RSC_ACCESS_ID4 is null
	  and jut.header = v_header
  	  and jut.INTERFACE_TYPE = v_intf_type
      union all
      select user_sequence, TERR_RSC_ID, lay_seq_num, header,
      5 qual_type_num, TERR_RSC_ACCESS_ID5 TERR_RSC_ACCESS_ID,
      TRANS_ACCESS_CODE5 TRANS_ACCESS_CODE
      FROM JTY_WEBADI_RESOURCES jut
      where jut.USER_SEQUENCE = v_user_sequence
      and jut.TRANS_ACCESS_CODE5 is not null
	  and jut.TERR_RSC_ACCESS_ID5 is null
	  and jut.header = v_header
  	  and jut.INTERFACE_TYPE = v_intf_type
      union all
      select user_sequence, TERR_RSC_ID,lay_seq_num, header,
      6 qual_type_num, TERR_RSC_ACCESS_ID6 TERR_RSC_ACCESS_ID,
      TRANS_ACCESS_CODE6 TRANS_ACCESS_CODE
      FROM JTY_WEBADI_RESOURCES jut
      where jut.USER_SEQUENCE = v_user_sequence
      and jut.TRANS_ACCESS_CODE6 is not null
	  and jut.TERR_RSC_ACCESS_ID6 is null
	  and jut.header = v_header
  	  and jut.INTERFACE_TYPE = v_intf_type
      union all
      select user_sequence, TERR_RSC_ID, lay_seq_num, header,
      7 qual_type_num, TERR_RSC_ACCESS_ID7 TERR_RSC_ACCESS_ID,
      TRANS_ACCESS_CODE7 TRANS_ACCESS_CODE
      FROM JTY_WEBADI_RESOURCES jut
      where jut.USER_SEQUENCE = v_user_sequence
      and jut.TRANS_ACCESS_CODE7 is not null
	  and jut.TERR_RSC_ACCESS_ID7 is null
	  and jut.header = v_header
  	  and jut.INTERFACE_TYPE = v_intf_type
      union all
      select user_sequence, TERR_RSC_ID, lay_seq_num, header,
      8 qual_type_num, TERR_RSC_ACCESS_ID8 TERR_RSC_ACCESS_ID,
      TRANS_ACCESS_CODE8 TRANS_ACCESS_CODE
      FROM JTY_WEBADI_RESOURCES jut
      where jut.USER_SEQUENCE = v_user_sequence
      and jut.TRANS_ACCESS_CODE8 is not null
	  and jut.TERR_RSC_ACCESS_ID8 is null
	  and jut.header = v_header
  	  and jut.INTERFACE_TYPE = v_intf_type
      union all
      select user_sequence, TERR_RSC_ID, lay_seq_num, header,
      9 qual_type_num, TERR_RSC_ACCESS_ID9 TERR_RSC_ACCESS_ID,
      TRANS_ACCESS_CODE9 TRANS_ACCESS_CODE
      FROM JTY_WEBADI_RESOURCES jut
      where jut.USER_SEQUENCE = v_user_sequence
      and jut.TRANS_ACCESS_CODE9 is not null
	  and jut.TERR_RSC_ACCESS_ID9 is null
	  and jut.header = v_header
  	  and jut.INTERFACE_TYPE = v_intf_type
      union all
      select user_sequence, TERR_RSC_ID, lay_seq_num, header,
      10 qual_type_num, TERR_RSC_ACCESS_ID10 TERR_RSC_ACCESS_ID,
      TRANS_ACCESS_CODE10 TRANS_ACCESS_CODE
      FROM JTY_WEBADI_RESOURCES jut
      where jut.USER_SEQUENCE = v_user_sequence
      and jut.TRANS_ACCESS_CODE10 is not null
	  and jut.TERR_RSC_ACCESS_ID10 is null
	  and jut.header = v_header
  	  and jut.INTERFACE_TYPE = v_intf_type) sub
	  where sub.user_sequence = jq.user_sequence
	  and sub.qual_type_num = jq.QUAL_TYPE_NUM
	  and sub.lay_seq_num = jwot.lay_seq_num
	  and sub.user_sequence = jwot.user_sequence
	  and sub.header = jwot.header
	  and jwot.interface_type = v_intf_type
	  and jwot.status is null;

	cursor get_u_rsc_access_csr(
	   v_user_sequence  number,
	   v_header			varchar2,
	   v_intf_type		varchar2) is
	   select sub.TERR_RSC_ACCESS_ID,
       jwot.LAST_UPDATE_DATE, jwot.LAST_UPDATED_BY,
       jwot.CREATION_DATE, jwot.CREATED_BY, jwot.LAST_UPDATE_LOGIN,
       sub.TERR_RSC_ID, jq.QUAL_TYPE_NAME ACCESS_TYPE,
       jwot.ORG_ID, sub.TRANS_ACCESS_CODE
      from JTY_WEBADI_QUAL_TYPE_HEADER jq,
	  JTY_WEBADI_OTH_TERR_INTF jwot,
  	  (
      select user_sequence, TERR_RSC_ID, lay_seq_num, header,
      1 qual_type_num, TERR_RSC_ACCESS_ID1 TERR_RSC_ACCESS_ID,
      TRANS_ACCESS_CODE1 TRANS_ACCESS_CODE
      FROM JTY_WEBADI_RESOURCES jut
      where jut.USER_SEQUENCE = v_user_sequence
      and jut.TRANS_ACCESS_CODE1 is not null
	  and jut.TERR_RSC_ACCESS_ID1 is not null
	  and jut.header = v_header
  	  and jut.INTERFACE_TYPE = v_intf_type
      union all
      select user_sequence, TERR_RSC_ID, lay_seq_num, header,
      2 qual_type_num, TERR_RSC_ACCESS_ID2 TERR_RSC_ACCESS_ID,
      TRANS_ACCESS_CODE2 TRANS_ACCESS_CODE
      FROM JTY_WEBADI_RESOURCES jut
      where jut.USER_SEQUENCE = v_user_sequence
      and jut.TRANS_ACCESS_CODE2 is not null
	  and jut.TERR_RSC_ACCESS_ID2 is not null
	  and jut.header = v_header
  	  and jut.INTERFACE_TYPE = v_intf_type
      union all
      select user_sequence, TERR_RSC_ID, lay_seq_num, header,
      3 qual_type_num, TERR_RSC_ACCESS_ID3 TERR_RSC_ACCESS_ID,
      TRANS_ACCESS_CODE3 TRANS_ACCESS_CODE
      FROM JTY_WEBADI_RESOURCES jut
      where jut.USER_SEQUENCE = v_user_sequence
      and jut.TRANS_ACCESS_CODE3 is not null
	  and jut.TERR_RSC_ACCESS_ID3 is not null
	  and jut.header = v_header
  	  and jut.INTERFACE_TYPE = v_intf_type
      union all
      select user_sequence, TERR_RSC_ID, lay_seq_num, header,
      4 qual_type_num, TERR_RSC_ACCESS_ID4 TERR_RSC_ACCESS_ID,
      TRANS_ACCESS_CODE4 TRANS_ACCESS_CODE
      FROM JTY_WEBADI_RESOURCES jut
      where jut.USER_SEQUENCE = v_user_sequence
      and jut.TRANS_ACCESS_CODE4 is not null
	  and jut.TERR_RSC_ACCESS_ID4 is not null
	  and jut.header = v_header
  	  and jut.INTERFACE_TYPE = v_intf_type
      union all
      select user_sequence, TERR_RSC_ID, lay_seq_num, header,
      5 qual_type_num, TERR_RSC_ACCESS_ID5 TERR_RSC_ACCESS_ID,
      TRANS_ACCESS_CODE5 TRANS_ACCESS_CODE
      FROM JTY_WEBADI_RESOURCES jut
      where jut.USER_SEQUENCE = v_user_sequence
      and jut.TRANS_ACCESS_CODE5 is not null
	  and jut.TERR_RSC_ACCESS_ID5 is not null
	  and jut.header = v_header
  	  and jut.INTERFACE_TYPE = v_intf_type
      union all
      select user_sequence, TERR_RSC_ID,lay_seq_num, header,
      6 qual_type_num, TERR_RSC_ACCESS_ID6 TERR_RSC_ACCESS_ID,
      TRANS_ACCESS_CODE6 TRANS_ACCESS_CODE
      FROM JTY_WEBADI_RESOURCES jut
      where jut.USER_SEQUENCE = v_user_sequence
      and jut.TRANS_ACCESS_CODE6 is not null
	  and jut.TERR_RSC_ACCESS_ID6 is not null
	  and jut.header = v_header
  	  and jut.INTERFACE_TYPE = v_intf_type
      union all
      select user_sequence, TERR_RSC_ID, lay_seq_num, header,
      7 qual_type_num, TERR_RSC_ACCESS_ID7 TERR_RSC_ACCESS_ID,
      TRANS_ACCESS_CODE7 TRANS_ACCESS_CODE
      FROM JTY_WEBADI_RESOURCES jut
      where jut.USER_SEQUENCE = v_user_sequence
      and jut.TRANS_ACCESS_CODE7 is not null
	  and jut.TERR_RSC_ACCESS_ID7 is not null
	  and jut.header = v_header
  	  and jut.INTERFACE_TYPE = v_intf_type
      union all
      select user_sequence, TERR_RSC_ID, lay_seq_num, header,
      8 qual_type_num, TERR_RSC_ACCESS_ID8 TERR_RSC_ACCESS_ID,
      TRANS_ACCESS_CODE8 TRANS_ACCESS_CODE
      FROM JTY_WEBADI_RESOURCES jut
      where jut.USER_SEQUENCE = v_user_sequence
      and jut.TRANS_ACCESS_CODE8 is not null
	  and jut.TERR_RSC_ACCESS_ID8 is not null
	  and jut.header = v_header
  	  and jut.INTERFACE_TYPE = v_intf_type
      union all
      select user_sequence, TERR_RSC_ID, lay_seq_num, header,
      9 qual_type_num, TERR_RSC_ACCESS_ID9 TERR_RSC_ACCESS_ID,
      TRANS_ACCESS_CODE9 TRANS_ACCESS_CODE
      FROM JTY_WEBADI_RESOURCES jut
      where jut.USER_SEQUENCE = v_user_sequence
      and jut.TRANS_ACCESS_CODE9 is not null
	  and jut.TERR_RSC_ACCESS_ID9 is not null
	  and jut.header = v_header
  	  and jut.INTERFACE_TYPE = v_intf_type
      union all
      select user_sequence, TERR_RSC_ID, lay_seq_num, header,
      10 qual_type_num, TERR_RSC_ACCESS_ID10 TERR_RSC_ACCESS_ID,
      TRANS_ACCESS_CODE10 TRANS_ACCESS_CODE
      FROM JTY_WEBADI_RESOURCES jut
      where jut.USER_SEQUENCE = v_user_sequence
      and jut.TRANS_ACCESS_CODE10 is not null
	  and jut.TERR_RSC_ACCESS_ID10 is not null
	  and jut.header = v_header
  	  and jut.INTERFACE_TYPE = v_intf_type) sub
	  where sub.user_sequence = jq.user_sequence
	  and sub.qual_type_num = jq.QUAL_TYPE_NUM
	  and sub.lay_seq_num = jwot.lay_seq_num
	  and sub.user_sequence = jwot.user_sequence
	  and sub.header = jwot.header
	  and jwot.interface_type = v_intf_type
	  and jwot.status is null;

  TYPE rsc_rec_type IS RECORD
  ( LAY_SEQ_NUM		   		  number_tbl_type,
    TERR_RSC_ID		   		  number_tbl_type,
  	LAST_UPDATE_DATE		  date_tbl_type,
	LAST_UPDATED_BY	  		  number_tbl_type,
    CREATION_DATE			  date_tbl_type,
	CREATED_BY	   			  number_tbl_type,
	LAST_UPDATE_LOGIN		  number_tbl_type,
    TERR_ID					  number_tbl_type,
	RESOURCE_ID				  number_tbl_type,
	RESOURCE_TYPE			  varchar2_tbl_type,
    ROLE_CODE				  varchar2_tbl_type,
	PRIMARY_CONTACT_FLAG	  varchar2_tbl_type,
	START_DATE_ACTIVE		  date_tbl_type,
    END_DATE_ACTIVE			  date_tbl_type,
	ORG_ID			   	  	  number_tbl_type,
	FULL_ACCESS_FLAG		  varchar2_tbl_type,
    GROUP_ID		  		  number_tbl_type,
	SECURITY_GROUP_ID		  number_tbl_type,
	PERSON_ID				  number_tbl_type,
    OBJECT_VERSION_NUMBER	  number_tbl_type,
	ATTRIBUTE_CATEGORY		  varchar2_tbl_type,
	ATTRIBUTE1				  varchar2_tbl_type,
    ATTRIBUTE2				  varchar2_tbl_type,
	ATTRIBUTE3				  varchar2_tbl_type,
	ATTRIBUTE4				  varchar2_tbl_type,
    ATTRIBUTE5				  varchar2_tbl_type,
	ATTRIBUTE6				  varchar2_tbl_type,
	ATTRIBUTE7				  varchar2_tbl_type,
    ATTRIBUTE8				  varchar2_tbl_type,
	ATTRIBUTE9				  varchar2_tbl_type,
	ATTRIBUTE10				  varchar2_tbl_type,
    ATTRIBUTE11				  varchar2_tbl_type,
	ATTRIBUTE12				  varchar2_tbl_type,
	ATTRIBUTE13				  varchar2_tbl_type,
    ATTRIBUTE14				  varchar2_tbl_type,
	ATTRIBUTE15				  varchar2_tbl_type
	);

	 TYPE rsc_access_rec_type IS RECORD(
       TERR_RSC_ACCESS_ID	  number_tbl_type,
       LAST_UPDATE_DATE		  date_tbl_type,
       LAST_UPDATED_BY		  number_tbl_type,
       CREATION_DATE		  date_tbl_type,
       CREATED_BY	 		  number_tbl_type,
       LAST_UPDATE_LOGIN	  number_tbl_type,
       TERR_RSC_ID			  number_tbl_type,
       ACCESS_TYPE			  varchar2_tbl_type,
	   TRANS_ACCESS_CODE	  varchar2_tbl_type,
       ORG_ID			 	  number_tbl_type);

  l_rsc_rec 		  rsc_rec_type;
  l_get_terr_rsc_rec  rsc_rec_type;
  l_rsc_access_rec	  rsc_access_rec_type;

  l_header varchar2(15) := 'RSC';
  l_intf_type varchar2(1) := 'U';
  l_action_flag varchar2(1);
  l_api_version_number      CONSTANT NUMBER   := 1.0;
  X_Msg_Count		 number;

-- cursor below has been added for bug 8295746
  CURSOR GET_RSC_TERR_CSR(
  v_user_sequence	 number,
  v_intf_type		 varchar2,
  v_header			 varchar2,
  v_action_flag		 varchar2) IS
  SELECT DISTINCT jwot.TERR_ID
  from
    JTY_WEBADI_OTH_TERR_INTF jwot,
    JTY_WEBADI_RESOURCES jwr,
    jtf_rs_resource_extns res
  where jwr.RESOURCE_ID = res.resource_id(+)
    and jwr.user_sequence = jwot.user_sequence
    and jwr.interface_type = jwot.interface_type
    and jwot.lay_seq_num = jwr.lay_seq_num
    and jwot.user_sequence = v_user_sequence
    and jwot.interface_type = v_intf_type
    and jwot.header = v_header
    and jwot.status is null
    and jwr.header = jwot.header
    and jwot.action_flag = v_action_flag;

BEGIN

  --l_action_flag := p_action_flag;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_action_flag := 'C';

  -- process resource records
  open get_rsc_csr(p_user_sequence, l_intf_type, l_header, l_action_flag);
  fetch get_rsc_csr bulk collect into l_rsc_rec.LAY_SEQ_NUM,
  		l_rsc_rec.TERR_RSC_ID, l_rsc_rec.LAST_UPDATE_DATE, l_rsc_rec.LAST_UPDATED_BY,
  		l_rsc_rec.CREATION_DATE, l_rsc_rec.CREATED_BY, l_rsc_rec.LAST_UPDATE_LOGIN,
  		l_rsc_rec.TERR_ID, l_rsc_rec.RESOURCE_ID, l_rsc_rec.RESOURCE_TYPE,
  		l_rsc_rec.ROLE_CODE, l_rsc_rec.PRIMARY_CONTACT_FLAG, l_rsc_rec.START_DATE_ACTIVE,
  		l_rsc_rec.END_DATE_ACTIVE, l_rsc_rec.ORG_ID, l_rsc_rec.FULL_ACCESS_FLAG,
  		l_rsc_rec.GROUP_ID, l_rsc_rec.SECURITY_GROUP_ID, l_rsc_rec.PERSON_ID,
  		l_rsc_rec.OBJECT_VERSION_NUMBER, l_rsc_rec.ATTRIBUTE_CATEGORY, l_rsc_rec.ATTRIBUTE1,
  		l_rsc_rec.ATTRIBUTE2, l_rsc_rec.ATTRIBUTE3, l_rsc_rec.ATTRIBUTE4,
  		l_rsc_rec.ATTRIBUTE5, l_rsc_rec.ATTRIBUTE6, l_rsc_rec.ATTRIBUTE7,
  		l_rsc_rec.ATTRIBUTE8, l_rsc_rec.ATTRIBUTE9, l_rsc_rec.ATTRIBUTE10,
  		l_rsc_rec.ATTRIBUTE11, l_rsc_rec.ATTRIBUTE12, l_rsc_rec.ATTRIBUTE13,
  		l_rsc_rec.ATTRIBUTE14, l_rsc_rec.ATTRIBUTE15;
  close get_rsc_csr;

	  -- direct insert into the table since the package JTF_TERRITORY_RESOURCE_PVT
	  -- doesnot support flex field insert
  if (l_action_flag = 'C' AND l_rsc_rec.RESOURCE_ID.count > 0) then
    --dbms_output.put_line('Create territory resource information, rowcount: ' || l_rsc_rec.RESOURCE_ID.count);
    forall i in l_rsc_rec.RESOURCE_ID.first..l_rsc_rec.RESOURCE_ID.last
       INSERT INTO JTF_TERR_RSC_ALL (
          TERR_RSC_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
          CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
          TERR_ID, RESOURCE_ID, RESOURCE_TYPE,
          ROLE, PRIMARY_CONTACT_FLAG, START_DATE_ACTIVE,
          END_DATE_ACTIVE, ORG_ID, FULL_ACCESS_FLAG,
          GROUP_ID, SECURITY_GROUP_ID, PERSON_ID,
          OBJECT_VERSION_NUMBER, ATTRIBUTE_CATEGORY, ATTRIBUTE1,
          ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4,
          ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7,
          ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
          ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13,
          ATTRIBUTE14, ATTRIBUTE15)
		VALUES ( JTF_TERR_RSC_s.nextval, l_rsc_rec.LAST_UPDATE_DATE(i),
		  l_rsc_rec.LAST_UPDATED_BY(i), l_rsc_rec.CREATION_DATE(i),
		  l_rsc_rec.CREATED_BY(i), l_rsc_rec.LAST_UPDATE_LOGIN(i),
          l_rsc_rec.TERR_ID(i), l_rsc_rec.RESOURCE_ID(i), l_rsc_rec.RESOURCE_TYPE(i),
          l_rsc_rec.ROLE_CODE(i), l_rsc_rec.PRIMARY_CONTACT_FLAG(i), l_rsc_rec.START_DATE_ACTIVE(i),
          l_rsc_rec.END_DATE_ACTIVE(i), l_rsc_rec.ORG_ID(i), l_rsc_rec.FULL_ACCESS_FLAG(i),
          l_rsc_rec.GROUP_ID(i), l_rsc_rec.SECURITY_GROUP_ID(i), l_rsc_rec.PERSON_ID(i),
          l_rsc_rec.OBJECT_VERSION_NUMBER(i), l_rsc_rec.ATTRIBUTE_CATEGORY(i), l_rsc_rec.ATTRIBUTE1(i),
          l_rsc_rec.ATTRIBUTE2(i), l_rsc_rec.ATTRIBUTE3(i), l_rsc_rec.ATTRIBUTE4(i),
          l_rsc_rec.ATTRIBUTE5(i), l_rsc_rec.ATTRIBUTE6(i), l_rsc_rec.ATTRIBUTE7(i),
          l_rsc_rec.ATTRIBUTE8(i), l_rsc_rec.ATTRIBUTE9(i), l_rsc_rec.ATTRIBUTE10(i),
          l_rsc_rec.ATTRIBUTE11(i), l_rsc_rec.ATTRIBUTE12(i), l_rsc_rec.ATTRIBUTE13(i),
          l_rsc_rec.ATTRIBUTE14(i), l_rsc_rec.ATTRIBUTE15(i) )
		RETURNING terr_rsc_id, resource_id, terr_id
		bulk collect into l_get_terr_rsc_rec.terr_rsc_id,
		  l_get_terr_rsc_rec.resource_id, l_get_terr_rsc_rec.terr_id;

	--dbms_output.put_line(' # records processed for create:  '||SQL%ROWCOUNT);

	  if (l_get_terr_rsc_rec.terr_rsc_id.count > 0) then
		forall i in l_get_terr_rsc_rec.terr_rsc_id.first..l_get_terr_rsc_rec.terr_rsc_id.last
		   update JTY_WEBADI_RESOURCES
  		   set terr_rsc_id = l_get_terr_rsc_rec.terr_rsc_id(i)
		   where resource_id = l_get_terr_rsc_rec.resource_id(i)
--		     and terr_id = l_get_terr_rsc_rec.terr_id(i)
			 and interface_type = l_intf_type
			 and user_sequence = p_user_sequence
			 and header = l_header
			 and terr_rsc_id is null;
	  end if;

  end if;

  l_action_flag := 'U';

  -- process resource records
  open get_rsc_csr(p_user_sequence, l_intf_type, l_header, l_action_flag);
  fetch get_rsc_csr bulk collect into l_rsc_rec.LAY_SEQ_NUM,
  		l_rsc_rec.TERR_RSC_ID, l_rsc_rec.LAST_UPDATE_DATE, l_rsc_rec.LAST_UPDATED_BY,
  		l_rsc_rec.CREATION_DATE, l_rsc_rec.CREATED_BY, l_rsc_rec.LAST_UPDATE_LOGIN,
  		l_rsc_rec.TERR_ID, l_rsc_rec.RESOURCE_ID, l_rsc_rec.RESOURCE_TYPE,
  		l_rsc_rec.ROLE_CODE, l_rsc_rec.PRIMARY_CONTACT_FLAG, l_rsc_rec.START_DATE_ACTIVE,
  		l_rsc_rec.END_DATE_ACTIVE, l_rsc_rec.ORG_ID, l_rsc_rec.FULL_ACCESS_FLAG,
  		l_rsc_rec.GROUP_ID, l_rsc_rec.SECURITY_GROUP_ID, l_rsc_rec.PERSON_ID,
  		l_rsc_rec.OBJECT_VERSION_NUMBER, l_rsc_rec.ATTRIBUTE_CATEGORY, l_rsc_rec.ATTRIBUTE1,
  		l_rsc_rec.ATTRIBUTE2, l_rsc_rec.ATTRIBUTE3, l_rsc_rec.ATTRIBUTE4,
  		l_rsc_rec.ATTRIBUTE5, l_rsc_rec.ATTRIBUTE6, l_rsc_rec.ATTRIBUTE7,
  		l_rsc_rec.ATTRIBUTE8, l_rsc_rec.ATTRIBUTE9, l_rsc_rec.ATTRIBUTE10,
  		l_rsc_rec.ATTRIBUTE11, l_rsc_rec.ATTRIBUTE12, l_rsc_rec.ATTRIBUTE13,
  		l_rsc_rec.ATTRIBUTE14, l_rsc_rec.ATTRIBUTE15;
  close get_rsc_csr;

	  -- direct insert into the table since the package JTF_TERRITORY_RESOURCE_PVT
	  -- doesnot support flex field insert
  if (l_action_flag = 'U' AND l_rsc_rec.TERR_RSC_ID.count > 0) then
    --dbms_output.put_line('Update territory resource information, rowcount: ' || l_rsc_rec.TERR_RSC_ID.count);

    forall i in l_rsc_rec.TERR_RSC_ID.first..l_rsc_rec.TERR_RSC_ID.last
	  UPDATE JTF_TERR_RSC_ALL
	  SET LAST_UPDATE_DATE = l_rsc_rec.LAST_UPDATE_DATE(i),
	    LAST_UPDATED_BY = l_rsc_rec.LAST_UPDATED_BY(i),
		LAST_UPDATE_LOGIN = l_rsc_rec.LAST_UPDATE_LOGIN(i),
        TERR_ID = l_rsc_rec.TERR_ID(i),
		RESOURCE_ID = l_rsc_rec.RESOURCE_ID(i),
		RESOURCE_TYPE = l_rsc_rec.RESOURCE_TYPE(i),
        ROLE = l_rsc_rec.ROLE_CODE(i),
		START_DATE_ACTIVE = l_rsc_rec.START_DATE_ACTIVE(i),
        END_DATE_ACTIVE = l_rsc_rec.END_DATE_ACTIVE(i),
		ORG_ID = l_rsc_rec.ORG_ID(i),
        GROUP_ID = l_rsc_rec.GROUP_ID(i),
		PERSON_ID = l_rsc_rec.PERSON_ID(i),
		ATTRIBUTE_CATEGORY = l_rsc_rec.ATTRIBUTE_CATEGORY(i),
		ATTRIBUTE1 = l_rsc_rec.ATTRIBUTE1(i),
        ATTRIBUTE2 = l_rsc_rec.ATTRIBUTE2(i),
		ATTRIBUTE3 = l_rsc_rec.ATTRIBUTE3(i),
		ATTRIBUTE4 = l_rsc_rec.ATTRIBUTE4(i),
        ATTRIBUTE5 = l_rsc_rec.ATTRIBUTE5(i),
		ATTRIBUTE6 = l_rsc_rec.ATTRIBUTE6(i),
		ATTRIBUTE7 = l_rsc_rec.ATTRIBUTE7(i),
        ATTRIBUTE8 = l_rsc_rec.ATTRIBUTE8(i),
		ATTRIBUTE9 = l_rsc_rec.ATTRIBUTE9(i),
		ATTRIBUTE10 = l_rsc_rec.ATTRIBUTE10(i),
        ATTRIBUTE11 = l_rsc_rec.ATTRIBUTE11(i),
		ATTRIBUTE12 = l_rsc_rec.ATTRIBUTE12(i),
		ATTRIBUTE13 = l_rsc_rec.ATTRIBUTE13(i),
        ATTRIBUTE14 = l_rsc_rec.ATTRIBUTE14(i),
		ATTRIBUTE15 = l_rsc_rec.ATTRIBUTE15(i)
	  WHERE TERR_RSC_ID = l_rsc_rec.TERR_RSC_ID(i);

	--dbms_output.put_line(' # records processed for update:  '||SQL%ROWCOUNT);
  end if;

  --Added for bug 8295746
  FOR rsc_terr_id IN  GET_RSC_TERR_CSR(p_user_sequence, l_intf_type, l_header, l_action_flag)
  LOOP
     JTY_TERR_ENGINE_GEN_PVT.update_resource_person_id( p_terr_id  => rsc_terr_id.terr_id );
  END LOOP;
  -- End of addition

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
      open get_c_rsc_access_csr(P_USER_SEQUENCE, l_header, l_intf_type);
      fetch get_c_rsc_access_csr bulk collect into l_rsc_access_rec.TERR_RSC_ACCESS_ID,
       l_rsc_access_rec.LAST_UPDATE_DATE, l_rsc_access_rec.LAST_UPDATED_BY,
       l_rsc_access_rec.CREATION_DATE, l_rsc_access_rec.CREATED_BY,
	   l_rsc_access_rec.LAST_UPDATE_LOGIN,
       l_rsc_access_rec.TERR_RSC_ID, l_rsc_access_rec.ACCESS_TYPE,
       l_rsc_access_rec.ORG_ID, l_rsc_access_rec.TRANS_ACCESS_CODE;
      close get_c_rsc_access_csr;

      --dbms_output.put_line('Add Access to resource_id: '||l_terr_rsc_out_tbl(i).terr_rsc_id ||',access count: '||l_tr_access_tbl.count );
      if l_rsc_access_rec.TERR_RSC_ID.count > 0 then
		forall i in l_rsc_access_rec.TERR_RSC_ID.first..l_rsc_access_rec.TERR_RSC_ID.last
          INSERT INTO JTF_TERR_RSC_ACCESS_ALL(
            TERR_RSC_ACCESS_ID,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            TERR_RSC_ID,
            ACCESS_TYPE,
       	   	TRANS_ACCESS_CODE,
            ORG_ID)
		  VALUES (
            JTF_TERR_RSC_ACCESS_s.nextval,
            l_rsc_access_rec.LAST_UPDATE_DATE(i),
            l_rsc_access_rec.LAST_UPDATED_BY(i),
            l_rsc_access_rec.CREATION_DATE(i),
            l_rsc_access_rec.CREATED_BY(i),
            l_rsc_access_rec.LAST_UPDATE_LOGIN(i),
            l_rsc_access_rec.TERR_RSC_ID(i),
            l_rsc_access_rec.ACCESS_TYPE(i),
            l_rsc_access_rec.TRANS_ACCESS_CODE(i),
            l_rsc_access_rec.ORG_ID(i)
           );

		forall i in l_rsc_access_rec.TERR_RSC_ID.first..l_rsc_access_rec.TERR_RSC_ID.last
      	  update JTY_WEBADI_OTH_TERR_INTF jwot
    	  set status = x_return_status
    	  where exists
    	    (select 1 from JTY_WEBADI_RESOURCES jwr
    		 where jwr.LAY_SEQ_NUM = jwot.LAY_SEQ_NUM
    		   and jwr.header = jwot.header
    		   and jwr.user_sequence = jwot.user_sequence
    		   and jwr.interface_type = jwot.interface_type
			   and jwr.terr_rsc_id+0 = l_rsc_access_rec.terr_rsc_id(i))
    		and jwot.USER_SEQUENCE = p_user_sequence
    		and jwot.header = l_header
    		and jwot.interface_type = l_intf_type
    		and jwot.lay_seq_num is not null
    		and jwot.status is null;
	  end if; -- create resource access type

	  exception
	  when others then
	    x_return_status := FND_API.G_RET_STS_ERROR;
		fnd_message.clear;
   	  	fnd_message.set_name ('JTF', 'JTY_OTH_TERR_CREATE_ACCESS');
   	  	X_Msg_Data := fnd_message.get();

  		forall i in l_rsc_access_rec.TERR_RSC_ID.first..l_rsc_access_rec.TERR_RSC_ID.last
      	  update JTY_WEBADI_OTH_TERR_INTF jwot
    	  set status = x_return_status,
		  error_msg = x_msg_data
    	  where exists
    	    (select 1 from JTY_WEBADI_RESOURCES jwr
    		 where jwr.LAY_SEQ_NUM = jwot.LAY_SEQ_NUM
    		   and jwr.header = jwot.header
    		   and jwr.user_sequence = jwot.user_sequence
    		   and jwr.interface_type = jwot.interface_type
			   and jwr.terr_rsc_id+0 = l_rsc_access_rec.terr_rsc_id(i))
    		and jwot.USER_SEQUENCE = p_user_sequence
    		and jwot.header = l_header
    		and jwot.interface_type = l_intf_type
    		and jwot.status is null;
    END;

	BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
      open get_u_rsc_access_csr(P_USER_SEQUENCE, l_header, l_intf_type);
      fetch get_u_rsc_access_csr bulk collect into l_rsc_access_rec.TERR_RSC_ACCESS_ID,
       l_rsc_access_rec.LAST_UPDATE_DATE, l_rsc_access_rec.LAST_UPDATED_BY,
       l_rsc_access_rec.CREATION_DATE, l_rsc_access_rec.CREATED_BY,
	   l_rsc_access_rec.LAST_UPDATE_LOGIN,
       l_rsc_access_rec.TERR_RSC_ID, l_rsc_access_rec.ACCESS_TYPE,
       l_rsc_access_rec.ORG_ID, l_rsc_access_rec.TRANS_ACCESS_CODE;
      close get_u_rsc_access_csr;

      --dbms_output.put_line('Add Access to resource_id: '||l_terr_rsc_out_tbl(i).terr_rsc_id ||',access count: '||l_tr_access_tbl.count );
      if l_rsc_access_rec.TERR_RSC_ID.count > 0 then
		forall i in l_rsc_access_rec.TERR_RSC_ID.first..l_rsc_access_rec.TERR_RSC_ID.last
            Update JTF_TERR_RSC_ACCESS_ALL
            SET
              LAST_UPDATE_DATE = l_rsc_access_rec.LAST_UPDATE_DATE(i),
              LAST_UPDATED_BY = l_rsc_access_rec.LAST_UPDATED_BY(i),
              LAST_UPDATE_LOGIN = l_rsc_access_rec.LAST_UPDATE_LOGIN(i),
              TERR_RSC_ID = l_rsc_access_rec.TERR_RSC_ID(i),
              ACCESS_TYPE = l_rsc_access_rec.ACCESS_TYPE(i),
              TRANS_ACCESS_CODE = l_rsc_access_rec.TRANS_ACCESS_CODE(i),
              ORG_ID = l_rsc_access_rec.ORG_ID(i)
            where TERR_RSC_ACCESS_ID = l_rsc_access_rec.TERR_RSC_ACCESS_ID(i);

		forall i in l_rsc_access_rec.TERR_RSC_ID.first..l_rsc_access_rec.TERR_RSC_ID.last
      	  update JTY_WEBADI_OTH_TERR_INTF jwot
    	  set status = x_return_status
    	  where exists
    	    (select 1 from JTY_WEBADI_RESOURCES jwr
    		 where jwr.LAY_SEQ_NUM = jwot.LAY_SEQ_NUM
    		   and jwr.header = jwot.header
    		   and jwr.user_sequence = jwot.user_sequence
    		   and jwr.interface_type = jwot.interface_type
			   and jwr.terr_rsc_id+0 = l_rsc_access_rec.terr_rsc_id(i))
    		and jwot.USER_SEQUENCE = p_user_sequence
    		and jwot.header = l_header
    		and jwot.interface_type = l_intf_type
    		and jwot.status is null;
	  end if;

	  exception
	  when others then
	    x_return_status := FND_API.G_RET_STS_ERROR;
		fnd_message.clear;
   	  	fnd_message.set_name ('JTF', 'JTY_OTH_TERR_UPDATE_ACCESS');
   	  	X_Msg_Data := fnd_message.get();

  		forall i in l_rsc_access_rec.TERR_RSC_ID.first..l_rsc_access_rec.TERR_RSC_ID.last
      	  update JTY_WEBADI_OTH_TERR_INTF jwot
    	  set status = x_return_status,
		  error_msg = x_msg_data
    	  where exists
    	    (select 1 from JTY_WEBADI_RESOURCES jwr
    		 where jwr.LAY_SEQ_NUM = jwot.LAY_SEQ_NUM
    		   and jwr.header = jwot.header
    		   and jwr.user_sequence = jwot.user_sequence
    		   and jwr.interface_type = jwot.interface_type
			   and jwr.terr_rsc_id+0 = l_rsc_access_rec.terr_rsc_id(i))
    		and jwot.USER_SEQUENCE = p_user_sequence
    		and jwot.header = l_header
    		and jwot.interface_type = l_intf_type
    		and jwot.status is null;
    END;

  exception
    when others then
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  fnd_message.clear;
      fnd_message.set_name ('JTF', 'JTY_OTH_TERR_UPDATE_RSC');
      X_Msg_Data := fnd_message.get();

  	  update JTY_WEBADI_OTH_TERR_INTF jwot
	  set status = x_return_status,
	  error_msg = X_Msg_Data
	  where exists
	    (select 1 from JTY_WEBADI_RESOURCES jwr
		 where jwr.LAY_SEQ_NUM = jwot.LAY_SEQ_NUM
		   and jwr.header = jwot.header
		   and jwr.user_sequence = jwot.user_sequence
		   and jwr.interface_type = jwot.interface_type)
		and jwot.USER_SEQUENCE = p_user_sequence
		and jwot.header = l_header
		and jwot.interface_type = l_intf_type
		and jwot.status is null;

END UPDATE_TERR_RSC;

PROCEDURE UPDATE_TERR_DEF(
    x_errbuf            	  OUT NOCOPY VARCHAR2,
    x_retcode           	  OUT NOCOPY VARCHAR2,
    P_USER_SEQUENCE 			  	  IN  NUMBER,
	--p_ORG_id						  IN  NUMBER,
	p_usage_id						  IN  NUMBER,
	p_user_id						  IN  NUMBER
) IS

  	--l_api_version_number      CONSTANT NUMBER   := 1.0;
  	x_return_status	 varchar2(255);
  	X_Msg_Count		 number;
  	X_Msg_Data		 varchar2(255);

    l_rowid	   varchar2(30) := null;
	l_action_flag varchar2(1);
	l_header	  varchar2(30);
	l_intf_type	  varchar2(1) := 'U';
	l_row_count	  number;
	l_row_count2	  number;
	l_sql			  varchar2(5000);
	l_login_id 		  number := fnd_global.login_id;

	l_status		  varchar2_tbl_type;
	l_error_msg		  varchar2_tbl_type;
	l_lay_seq_num	  number_tbl_type;

BEGIN
  debugmsg('UPDATE_TERR_DEF: P_USER_SEQUENCE : ' || P_USER_SEQUENCE);
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --l_action_flag := p_action_flag;
  --fnd_file.put_line( FND_FILE.OUTPUT, 'Program starting....., sequence: '||p_USER_SEQUENCE ||', user_id: '||p_user_id);
  --dbms_output.put_line('Program starting....., sequence: '||p_USER_SEQUENCE ||', user_id: '||p_user_id);

  begin
  -- remove old inserted values from the interface table
  -- added 05/26/2006, bug 5249085
    delete from JTY_WEBADI_OTH_TERR_INTF
    where interface_type = l_intf_type
      and status is not null;
    --dbms_output.put_line('removed old data, row count: '||SQL%ROWCOUNT);
	commit;

	exception
	  when others then
	    rollback;
  end;

  -- initial operating unit
  mo_global.init('JTF');

  -- get hierarchy for territory
  --dbms_output.put_line('get hierarchy');
    debugmsg('UPDATE_TERR_DEF: get hierarchy : Before ' );
  get_hierarchy
    ( p_user_sequence  => p_user_sequence,
  	  p_intf_type	   => l_intf_type,
	  x_return_status  => x_return_status,
	  x_msg_data	   => x_msg_data );

  --dbms_output.put_line('get hierarchy completed, status: ' ||x_return_status);
  debugmsg('UPDATE_TERR_DEF: get hierarchy completed, status: ' ||x_return_status );

  if x_return_status = FND_API.G_RET_STS_SUCCESS then
      --dbms_output.put_line('set create record ');
      -- set all create records id to null
      debugmsg('UPDATE_TERR_DEF: SET_CREATE_RECORDS : Before ' );
      SET_CREATE_RECORDS(
      p_user_sequence 	=> p_user_sequence,
      p_intf_type		=> l_intf_type);

      --dbms_output.put_line('update terr qual id');
      debugmsg('UPDATE_TERR_DEF: update terr qual id : Before ' );
      l_header := 'QUAL';
      UPDATE_TERR_QUAL_ID(
          P_USER_SEQUENCE	=> p_user_sequence,
    	  P_INTF_TYPE		=> l_intf_type,
    	  P_HEADER			=> l_header);
     debugmsg('UPDATE_TERR_DEF: validate_territory_records : Before ' );
    -- validate all records
  --dbms_output.put_line('validating record');
    validate_territory_records
    ( p_user_sequence 		=> p_user_sequence,
      P_INTF_TYPE				=> l_intf_type,
   	  x_return_status			=> x_return_status,
   	  X_MSG_DATA				=> x_msg_data);
  --dbms_output.put_line('validating record completed, status: '||x_return_status);
   debugmsg('UPDATE_TERR_DEF: validating record completed, status: '||x_return_status );

    if x_return_status = FND_API.G_RET_STS_SUCCESS then
      -- process qualifier records
      --dbms_output.put_line(' Call delete records procedure...');
      l_action_flag := 'D';
	  delete_records(
	    P_USER_SEQUENCE => p_user_sequence,
	    P_INTF_TYPE 	  => l_intf_type ,
		p_action_flag	  => l_action_flag);

      -- process territory definition records
  	  --dbms_output.put_line(' process terr header records... ');
      debugmsg('UPDATE_TERR_DEF: UPDATE_TERR (C) : Before' );
      l_action_flag := 'C';
      UPDATE_TERR(
        p_user_sequence    => p_user_sequence,
        p_action_flag	   => l_action_flag,
        x_return_status    => x_return_status,
        x_msg_data	  	   => x_msg_data);

     debugmsg('UPDATE_TERR_DEF: UPDATE_TERR (C) completed, status: '||x_return_status );

      if x_return_status = FND_API.G_RET_STS_SUCCESS then
	  -- process terr update
  	  --dbms_output.put_line(' process terr update... ');
        l_action_flag := 'U';
        debugmsg('UPDATE_TERR_DEF: UPDATE_TERR (U) : Before' );
        UPDATE_TERR(
          p_user_sequence => p_user_sequence,
          p_action_flag	  => l_action_flag,
          x_return_status => x_return_status,
          x_msg_data	  => x_msg_data);

          debugmsg('UPDATE_TERR_DEF: UPDATE_TERR (U) completed, status: '||x_return_status );

      if x_return_status = FND_API.G_RET_STS_SUCCESS then
        -- process resources
  	  --dbms_output.put_line(' process resource records');
       debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_RSC  : Before' );
        UPDATE_TERR_RSC(P_USER_SEQUENCE	 => p_user_sequence,
		  --p_action_flag	  => l_action_flag,
          x_return_status => x_return_status,
          x_msg_data	  => x_msg_data);

        debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_RSC completed, status: '||x_return_status );

    	if x_return_status = FND_API.G_RET_STS_SUCCESS then
        	-- process qualifier
  	  --dbms_output.put_line(' process qualifier records');
  	    debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_QUAL  : Before' );
          UPDATE_TERR_QUAL(P_USER_SEQUENCE	 => p_user_sequence,
		    --p_action_flag   => l_action_flag,
        	x_return_status => x_return_status,
        	x_msg_data	  	=> x_msg_data);
        	debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_QUAL completed, status: '||x_return_status );
        	debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_QUAL : x_msg_data : '||x_msg_data );
		else
		  select NVL(status,'S') status, NVL(error_msg,'Success') error_msg, lay_seq_num
		  bulk collect into l_status, l_error_msg, l_lay_seq_num
		  from JTY_WEBADI_OTH_TERR_INTF
		  where interface_type = l_intf_type
  		    and user_sequence = p_user_sequence;

		  -- rollback all updated info
		  debugmsg('UPDATE_TERR_DEF: UPDATE_TERR_QUAL : rollback all updated info : ' );
		  rollback;

		  forall i in l_lay_seq_num.first..l_lay_seq_num.last
		    update JTY_WEBADI_OTH_TERR_INTF
		    set status = l_status(i),
			error_msg = l_error_msg(i)
			where lay_seq_num = l_lay_seq_num(i)
			  and interface_type = l_intf_type
  		    and user_sequence = p_user_sequence;
    	end if;-- qualifier
	  else

		  select NVL(status,'S') status, NVL(error_msg,'Success') error_msg, lay_seq_num
		  bulk collect into l_status, l_error_msg, l_lay_seq_num
		  from JTY_WEBADI_OTH_TERR_INTF
		  where interface_type = l_intf_type
  		    and user_sequence = p_user_sequence;

		  -- rollback all updated info
		  rollback;

		  forall i in l_lay_seq_num.first..l_lay_seq_num.last
		    update JTY_WEBADI_OTH_TERR_INTF
		    set status = l_status(i),
			error_msg = l_error_msg(i)
			where lay_seq_num = l_lay_seq_num(i)
			  and interface_type = l_intf_type
  		    and user_sequence = p_user_sequence;
	  end if; -- resource
	  else

		  select NVL(status,'S') status, NVL(error_msg,'Success') error_msg, lay_seq_num
		  bulk collect into l_status, l_error_msg, l_lay_seq_num
		  from JTY_WEBADI_OTH_TERR_INTF
		  where interface_type = l_intf_type
  		    and user_sequence = p_user_sequence;

		  -- rollback all updated info
		  rollback;

		  forall i in l_lay_seq_num.first..l_lay_seq_num.last
		    update JTY_WEBADI_OTH_TERR_INTF
		    set status = l_status(i),
			error_msg = l_error_msg(i)
			where lay_seq_num = l_lay_seq_num(i)
			  and interface_type = l_intf_type
  		    and user_sequence = p_user_sequence;
	  end if; -- resource

	  else

	  select NVL(status,'S') status, NVL(error_msg,'Success') error_msg, lay_seq_num
	  bulk collect into l_status, l_error_msg, l_lay_seq_num
	  from JTY_WEBADI_OTH_TERR_INTF
	  where interface_type = l_intf_type
 		and user_sequence = p_user_sequence;

	  -- rollback all updated info
	  rollback;

	  forall i in l_lay_seq_num.first..l_lay_seq_num.last
	    update JTY_WEBADI_OTH_TERR_INTF
	    set status = l_status(i),
		error_msg = l_error_msg(i)
		where lay_seq_num = l_lay_seq_num(i)
		  and interface_type = l_intf_type
 		  and user_sequence = p_user_sequence;
	end if; -- territory
  else
    select NVL(status,'S') status, NVL(error_msg,'Success') error_msg, lay_seq_num
    bulk collect into l_status, l_error_msg, l_lay_seq_num
    from JTY_WEBADI_OTH_TERR_INTF
    where interface_type = l_intf_type
  	  and user_sequence = p_user_sequence;

    -- rollback all updated info
    rollback;

    forall i in l_lay_seq_num.first..l_lay_seq_num.last
      update JTY_WEBADI_OTH_TERR_INTF
      set status = l_status(i),
  	  error_msg = l_error_msg(i)
  	  where lay_seq_num = l_lay_seq_num(i)
  	    and interface_type = l_intf_type
  		and user_sequence = p_user_sequence;
  end if;  -- validation
  debugmsg('UPDATE_TERR_DEF: End : ' );
  x_errbuf := FND_API.G_RET_STS_SUCCESS;
  x_retcode := 0;
  --commit;

    exception
      WHEN others THEN
          debugmsg('UPDATE_TERR_DEF: End : exception : Others : ' || SQLERRM(SQLCODE()) );
      	  --fnd_file.put_line( FND_FILE.OUTPUT,'Exception: Others in upload');
      	  --fnd_file.put_line( FND_FILE.OUTPUT,' SQLERRM: ' || SQLERRM);
      	  --dbms_output.put_line( 'Exception: Others in upload');
      	  --dbms_output.put_line( ' SQLERRM: ' || SQLERRM);
		x_errbuf := sqlcode||': '||SQLERRM;
		x_retcode := 2;

END UPDATE_TERR_DEF;

END JTY_WEBADI_OTH_TERR_UPDATE_PKG;

/
