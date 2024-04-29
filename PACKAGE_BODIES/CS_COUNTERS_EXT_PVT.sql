--------------------------------------------------------
--  DDL for Package Body CS_COUNTERS_EXT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_COUNTERS_EXT_PVT" AS
-- $Header: csxvcteb.pls 120.2 2005/07/25 14:02:35 appldev ship $

-- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------
G_PKG_NAME	CONSTANT	VARCHAR2(30)	:= 'CS_Counters_EXT_PVT';
--G_USER		CONSTANT	VARCHAR2(30)	:= FND_GLOBAL.USER_ID;
--------------------------------------------------------------------------

-- ---------------------------------------------------------
-- Private program units
-- ---------------------------------------------------------

/*
    Object         : Disp
    Scope          : Private to package
    Description    : Temporary for debug TO BE REMOVED
    Parameters     : str - Message String
 */
procedure disp (str in varchar2) is
sStr varchar2(2000) ;
begin
  sStr := str;
  while length(sStr) > 0 loop
--    dbms_output.put_line(substr(sStr,1,80));
    if length(sStr) > 80 then
      sStr := substr(sStr,81);
    else
      sStr := null;
    end if;
  end loop;
end disp;

Procedure ExitWithErrMsg
(
	p_msg_name		in	varchar2,
	p_token1_name	in	varchar2	:=	null,
	p_token1_val	in	varchar2	:=	null,
	p_token2_name	in	varchar2	:=	null,
	p_token2_val	in	varchar2	:=	null,
	p_token3_name	in	varchar2	:=	null,
	p_token3_val	in	varchar2	:=	null,
	p_token4_name	in	varchar2	:=	null,
	p_token4_val	in	varchar2	:=	null
) is
begin
	FND_MESSAGE.SET_NAME('CS',p_msg_name);
	if p_token1_name is not null then
		FND_MESSAGE.SET_TOKEN(p_token1_name, p_token1_val);
	end if;
	if p_token2_name is not null then
		FND_MESSAGE.SET_TOKEN(p_token2_name, p_token2_val);
	end if;
	if p_token3_name is not null then
		FND_MESSAGE.SET_TOKEN(p_token3_name, p_token3_val);
	end if;
	if p_token4_name is not null then
		FND_MESSAGE.SET_TOKEN(p_token4_name, p_token4_val);
	end if;
	--
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
end ExitWithErrMsg;

PROCEDURE Initialize_Desc_Flex
(
	p_desc_flex	IN	DFF_Rec_Type,
	l_desc_flex	OUT	NOCOPY DFF_Rec_Type
) IS

BEGIN
	IF p_desc_flex.context = FND_API.G_MISS_CHAR THEN
		l_desc_flex.context := NULL;
	ELSE
		l_desc_flex.context := p_desc_flex.context;
	END IF;
	IF p_desc_flex.attribute1 = FND_API.G_MISS_CHAR THEN
		l_desc_flex.attribute1 := NULL;
	ELSE
		l_desc_flex.attribute1 := p_desc_flex.attribute1;
	END IF;
	IF p_desc_flex.attribute2 = FND_API.G_MISS_CHAR THEN
		l_desc_flex.attribute2 := NULL;
	ELSE
		l_desc_flex.attribute2 := p_desc_flex.attribute2;
	END IF;
	IF p_desc_flex.attribute3 = FND_API.G_MISS_CHAR THEN
		l_desc_flex.attribute3 := NULL;
	ELSE
		l_desc_flex.attribute3 := p_desc_flex.attribute3;
	END IF;
	IF p_desc_flex.attribute4 = FND_API.G_MISS_CHAR THEN
		l_desc_flex.attribute4 := NULL;
	ELSE
		l_desc_flex.attribute4 := p_desc_flex.attribute4;
	END IF;
	IF p_desc_flex.attribute5 = FND_API.G_MISS_CHAR THEN
		l_desc_flex.attribute5 := NULL;
	ELSE
		l_desc_flex.attribute5 := p_desc_flex.attribute5;
	END IF;
	IF p_desc_flex.attribute6 = FND_API.G_MISS_CHAR THEN
		l_desc_flex.attribute6 := NULL;
	ELSE
		l_desc_flex.attribute6 := p_desc_flex.attribute6;
	END IF;
	IF p_desc_flex.attribute7 = FND_API.G_MISS_CHAR THEN
		l_desc_flex.attribute7 := NULL;
	ELSE
		l_desc_flex.attribute7 := p_desc_flex.attribute7;
	END IF;
	IF p_desc_flex.attribute8 = FND_API.G_MISS_CHAR THEN
		l_desc_flex.attribute8 := NULL;
	ELSE
		l_desc_flex.attribute8 := p_desc_flex.attribute8;
	END IF;
	IF p_desc_flex.attribute9 = FND_API.G_MISS_CHAR THEN
		l_desc_flex.attribute9 := NULL;
	ELSE
		l_desc_flex.attribute9 := p_desc_flex.attribute9;
	END IF;
	IF p_desc_flex.attribute10 = FND_API.G_MISS_CHAR THEN
		l_desc_flex.attribute10 := NULL;
	ELSE
		l_desc_flex.attribute10 := p_desc_flex.attribute10;
	END IF;
	IF p_desc_flex.attribute11 = FND_API.G_MISS_CHAR THEN
		l_desc_flex.attribute11 := NULL;
	ELSE
		l_desc_flex.attribute11 := p_desc_flex.attribute11;
	END IF;
	IF p_desc_flex.attribute12 = FND_API.G_MISS_CHAR THEN
		l_desc_flex.attribute12 := NULL;
	ELSE
		l_desc_flex.attribute12 := p_desc_flex.attribute12;
	END IF;
	IF p_desc_flex.attribute13 = FND_API.G_MISS_CHAR THEN
		l_desc_flex.attribute13 := NULL;
	ELSE
		l_desc_flex.attribute13 := p_desc_flex.attribute13;
	END IF;
	IF p_desc_flex.attribute14 = FND_API.G_MISS_CHAR THEN
		l_desc_flex.attribute14 := NULL;
	ELSE
		l_desc_flex.attribute14 := p_desc_flex.attribute14;
	END IF;
	IF p_desc_flex.attribute15 = FND_API.G_MISS_CHAR THEN
		l_desc_flex.attribute15 := NULL;
	ELSE
		l_desc_flex.attribute15 := p_desc_flex.attribute15;
	END IF;

END Initialize_Desc_Flex;

--
--
--
-- ---------------------------------------------------------
--
-- Public program units
--
-- ---------------------------------------------------------
--
PROCEDURE VALIDATE_FORMULA_CTR
(
	p_api_version           IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit		IN	VARCHAR2	:= FND_API.G_FALSE,
	p_validation_level	IN	VARCHAR2	:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count		OUT     NOCOPY  NUMBER,
	x_msg_data		OUT     NOCOPY  VARCHAR2,
	p_counter_id		IN	NUMBER,
	x_valid_flag		OUT     NOCOPY  VARCHAR2
) is
  l_api_name           CONSTANT VARCHAR2(30) := 'VALIDATE_FORMULA_CTR';
  l_api_version        CONSTANT NUMBER   := 1.0;
  l_return_status_full      VARCHAR2(1);
  l_s_temp                  VARCHAR2(100);
  --Cursor to select all bind variables in bvars table for passed counter
  CURSOR ctr_bvars IS
    SELECT bind_var_name, mapped_counter_id AS counter_id,
           mapped_inv_item_id
    FROM cs_ctr_formula_bvars
    WHERE counter_id  = p_counter_id;
  l_cursor_handle INTEGER;
  l_n_temp INTEGER;
  l_formula varchar2(255);
  l_counter_reading NUMBER;
  l_bind_var_value NUMBER;
  l_bind_var_name VARCHAR2(255);
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CS_COUNTERS_EXT_PVT;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                            	           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          -- Invoke validation procedures
          null;
      END IF;
      --Validate counter group id only when validation level is not none
      IF ( P_validation_level > FND_API.G_VALID_LEVEL_NONE)
      THEN
        null;
	  END IF;
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      --Parameter Validations and initialization
      x_valid_flag := 'N';
      BEGIN
        SELECT formula_text INTO l_formula
        FROM cs_counters
        WHERE counter_id= p_counter_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          ExitWithErrMsg('CS_API_CTR_INVALID');
      END;

      -- Debug Message
      --Start Process
      begin
        --Open the cursor
        l_cursor_handle := dbms_sql.open_cursor;
        l_formula := 'SELECT '||l_formula||' FROM DUAL';
disp('Formula:'||l_formula||', ctr id:'||p_counter_id);
        -- parse the formula using dual table
        -- if formula is :a/2, in a sql statement it will become 'select :a/2 from dual'
        DBMS_SQL.PARSE(l_cursor_handle, l_formula, dbms_sql.native);
        --define column to select value
        DBMS_SQL.DEFINE_COLUMN(l_cursor_handle,1,l_counter_reading);
        FOR bvars IN ctr_bvars LOOP
          l_bind_var_value := 100;
          l_bind_var_name := ':'||ltrim(bvars.bind_var_name);
disp('Bind Var:'||l_bind_var_name||', Value:'||l_bind_var_value);
          DBMS_SQL.BIND_VARIABLE(l_cursor_handle, l_bind_var_name, l_bind_var_value);
        END LOOP bvars;
        l_n_temp := dbms_sql.execute(l_cursor_handle);
        IF dbms_sql.fetch_rows(l_cursor_handle) > 0 THEN
          dbms_sql.column_value(l_cursor_handle,1,l_counter_reading);
disp('Counter value:'||l_counter_reading);
          x_valid_flag := 'Y';
        END IF;
        DBMS_SQL.close_cursor(l_cursor_handle);
      EXCEPTION
        WHEN OTHERS THEN
          IF DBMS_SQL.IS_OPEN(l_cursor_handle) THEN
            DBMS_SQL.CLOSE_cursor(l_cursor_handle);
          END IF;
		if sqlcode <> -1008 then
             RAISE;
          else
		   x_valid_flag := 'N';
          end if;
       END;
disp('formula validation done...');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- End of API body
      --
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
disp('4');
           ROLLBACK TO CS_COUNTERS_EXT_PVT;
           x_return_status := FND_API.G_RET_STS_ERROR ;
           FND_MSG_PUB.Count_And_Get
           (p_count => x_msg_count,
            p_data => x_msg_data
           );
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
disp('5');
           ROLLBACK TO CS_COUNTERS_EXT_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get
           (
            p_count => x_msg_count,
            p_data => x_msg_data
           );
         WHEN OTHERS THEN
disp('6'||sqlerrm);
         ROLLBACK TO CS_COUNTERS_EXT_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
         END IF;
         FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count ,
          p_data => x_msg_data
         );
END VALIDATE_FORMULA_CTR;

PROCEDURE VALIDATE_GRPOP_CTR
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit		IN	VARCHAR2	:= FND_API.G_FALSE,
	p_validation_level	IN	VARCHAR2	:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT     NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_counter_id		IN	NUMBER,
	x_valid_flag		OUT     NOCOPY VARCHAR2
)
is
  l_api_name                CONSTANT VARCHAR2(30) := 'VALIDATE_GRPOP_CTR';
  l_api_version      CONSTANT NUMBER   := 1.0;
  l_return_status_full      VARCHAR2(1);
  l_s_temp                  VARCHAR2(100);
  CURSOR ctrs_to_be_calc IS
    SELECT distinct ctr.counter_id, ctr.derive_function,
      ctr.derive_counter_id, ctr.derive_property_id
    FROM cs_counters ctr
    WHERE ctr.counter_id = p_counter_id;
  CURSOR der_filters(b_counter_id number) IS
    SELECT filt.counter_property_id, filt.seq_no,filt.left_paren,
           filt.right_paren, filt.relational_operator,
           filt.logical_operator, filt.right_value,
           nvl(pro.default_value, 'NULL') as default_value,
           pro.property_data_type
    FROM cs_counter_der_filters filt, cs_counter_properties pro
    WHERE filt.counter_id = b_counter_id
      AND pro.counter_property_id(+) = filt.counter_property_id;
  l_sqlstr varchar2(2000);
  l_sqlwhere varchar2(1000);
  l_sqlfrom varchar2(1000);
  l_cursor_handle NUMBER;
  l_ctr_value NUMBER;
  l_n_temp NUMBER;

--variable and arrays for binding dbmssql
TYPE FILTS IS RECORD(
BINDNAME_DEFVAL VARCHAR2(240),
BINDVAL_DEFVAL VARCHAR2(240),
BINDNAME_RIGHTVAL VARCHAR2(240),
BINDVAL_RIGHTVAL VARCHAR2(240),
BINDNAME_CTRPROPID VARCHAR2(240),
BINDVAL_CTRPROPID NUMBER);

TYPE T1 is TABLE OF FILTS index by binary_integer;
T2 T1;
i NUMBER := 1;
lj NUMBER := 1;

BINDVAL_DERIVECTRID NUMBER;
l_bind_varname VARCHAR2(240);
l_bind_varvalc  VARCHAR2(240);
l_bind_varvaln  NUMBER;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CS_COUNTERS_EXT_PVT;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                            	           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      disp('1');
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          -- Invoke validation procedures
          null;
      END IF;
      disp('12');
      --Validate counter group id only when validation level is not none
      IF ( P_validation_level > FND_API.G_VALID_LEVEL_NONE)
      THEN
        null;
	  END IF;
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      --Parameter Validations and initialization
      x_valid_flag := 'N';
      disp('2');

      -- Debug Message
      begin
        FOR ctrs IN ctrs_to_be_calc LOOP
disp('Counter ID:'||ctrs.counter_id||', func:'||ctrs.derive_function||', der id:'||ctrs.derive_counter_id);

          i := 1;
          lj := 1;

          l_sqlstr := 'select '||ctrs.derive_function||'( counter_reading )';
          l_sqlstr := l_sqlstr || ' from cs_counter_values cv';
          l_sqlstr := l_sqlstr || ' where counter_value_id in (';
          l_sqlstr := l_sqlstr || ' select distinct cv.counter_value_id from ';
          l_sqlfrom := ' cs_counter_values cv';
          l_sqlwhere := '';
          FOR filts IN der_filters(ctrs.counter_id) LOOP
disp('Open for ctr:'||ctrs.counter_id) ;
disp('ctr_prop:'||filts.counter_property_id||',seq:'||filts.seq_no||',left:'||filts.left_paren||',right:'|| filts.right_paren||',rel opr:'||
filts.relational_operator||',logical:'|| filts.logical_operator||',right val:'|| filts.right_value||',def val:'||
filts.default_value );

            l_sqlfrom := l_sqlfrom ||', cs_counter_prop_values pv';
            l_sqlfrom := l_sqlfrom ||ltrim(rtrim(filts.seq_no));
            l_sqlwhere := l_sqlwhere || nvl(filts.left_paren,' ')||' nvl(pv';
            l_sqlwhere := l_sqlwhere || ltrim(rtrim(filts.seq_no));
            l_sqlwhere := l_sqlwhere || '.property_value, '; --||filts.default_value;

            T2(i).BINDVAL_DEFVAL := filts.default_value;
            T2(i).BINDNAME_DEFVAL := ':x_default_value'||ltrim(rtrim(filts.seq_no));

            if filts.property_data_type = 'NUMBER' then
               l_sqlwhere := l_sqlwhere ||':x_default_value'||ltrim(rtrim(filts.seq_no));
            elsif filts.property_data_type = 'DATE' then
               l_sqlwhere := l_sqlwhere || 'to_date( '||':x_default_value'||ltrim(rtrim(filts.seq_no))||','||'''DD-MON-RRRR'''||' )';
            else
               l_sqlwhere := l_sqlwhere || ':x_default_value'||ltrim(rtrim(filts.seq_no));
            end if;

            l_sqlwhere := l_sqlwhere ||')'||filts.relational_operator;

            T2(i).BINDVAL_RIGHTVAL := filts.right_value;
            T2(i).BINDNAME_RIGHTVAL := ':x_right_value'||ltrim(rtrim(filts.seq_no));

            if filts.property_data_type = 'NUMBER' then
              l_sqlwhere := l_sqlwhere || ':x_right_value'||ltrim(rtrim(filts.seq_no));
            elsif filts.property_data_type = 'DATE' then
              l_sqlwhere := l_sqlwhere || 'to_date( '||':x_right_value'||ltrim(rtrim(filts.seq_no))||','||'''DD-MON-RRRR'''||' )';
            else
              l_sqlwhere := l_sqlwhere || ':x_right_value'||ltrim(rtrim(filts.seq_no));
            end if;

            l_sqlwhere := l_sqlwhere || nvl(filts.right_paren,' ');
            l_sqlwhere := l_sqlwhere || filts.logical_operator;
            l_sqlwhere := l_sqlwhere || ' and pv'||ltrim(rtrim(filts.seq_no)) ;
            l_sqlwhere := l_sqlwhere || '.counter_value_id = cv.counter_value_id ';
            l_sqlwhere := l_sqlwhere || ' and pv'||ltrim(rtrim(filts.seq_no)) ;
            l_sqlwhere := l_sqlwhere || '.counter_property_id = ';

            T2(i).BINDVAL_CTRPROPID := filts.counter_property_id;
            T2(i).BINDNAME_CTRPROPID := ':x_ctr_prop_id'||ltrim(rtrim(filts.seq_no));
            l_sqlwhere := l_sqlwhere ||':x_ctr_prop_id'||ltrim(rtrim(filts.seq_no));

            l_sqlwhere := l_sqlwhere || ' and cv.counter_id = ';
            l_sqlwhere := l_sqlwhere || ':x_derive_counter_id';
          END LOOP;
          l_sqlstr := l_sqlstr || l_sqlfrom || ' where '||l_sqlwhere||')';
disp(l_sqlstr);
          l_cursor_handle := dbms_sql.open_cursor;
          DBMS_SQL.PARSE(l_cursor_handle, l_sqlstr, dbms_sql.native);
          DBMS_SQL.DEFINE_COLUMN(l_cursor_handle,1,l_ctr_value);

          BINDVAL_DERIVECTRID := ctrs.derive_counter_id;
          DBMS_SQL.BIND_VARIABLE(l_cursor_handle, ':x_derive_counter_id',BINDVAL_DERIVECTRID);

          while lj < i+1
          loop
            l_bind_varname := t2(lj).BINDNAME_DEFVAL;
            l_bind_varvalc := t2(lj).BINDVAL_DEFVAL;
            DBMS_SQL.BIND_VARIABLE(l_cursor_handle, l_bind_varname, l_bind_varvalc);
            l_bind_varname := t2(lj).BINDNAME_RIGHTVAL;
            l_bind_varvalc := t2(lj).BINDVAL_RIGHTVAL;
            DBMS_SQL.BIND_VARIABLE(l_cursor_handle, l_bind_varname, l_bind_varvalc);
            l_bind_varname := t2(lj).BINDNAME_CTRPROPID;
            l_bind_varvaln := t2(lj).BINDVAL_CTRPROPID;
            DBMS_SQL.BIND_VARIABLE(l_cursor_handle, l_bind_varname, l_bind_varvaln);
            lj:= lj+1;
          end loop;

          l_n_temp := dbms_sql.execute(l_cursor_handle);
          IF dbms_sql.fetch_rows(l_cursor_handle) > 0 THEN
              dbms_sql.column_value(l_cursor_handle,1,l_ctr_value);
disp('Counter value:'||l_ctr_value);
          END IF;
          DBMS_SQL.close_cursor(l_cursor_handle);
          x_valid_flag := 'Y';
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          IF DBMS_SQL.IS_OPEN(l_cursor_handle) THEN
            DBMS_SQL.CLOSE_cursor(l_cursor_handle);
          END IF;
          RAISE;
      END;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
      -- End of API body
      --
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        disp('4');
           ROLLBACK TO CS_COUNTERS_EXT_PVT;
           x_return_status := FND_API.G_RET_STS_ERROR ;
           FND_MSG_PUB.Count_And_Get
           (p_count => x_msg_count,
            p_data => x_msg_data
           );
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            disp('5');
           ROLLBACK TO CS_COUNTERS_EXT_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get
           (
            p_count => x_msg_count,
            p_data => x_msg_data
           );
         WHEN OTHERS THEN
      disp('6'||sqlerrm);
         ROLLBACK TO CS_COUNTERS_EXT_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
         END IF;
         FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count ,
          p_data => x_msg_data
         );
End VALIDATE_GRPOP_CTR;

PROCEDURE Check_Reqd_Param
(
	p_var1                  IN      NUMBER,
	p_param_name            IN      VARCHAR2,
	p_api_name              IN      VARCHAR2
) IS
BEGIN
	IF (NVL(p_var1,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) THEN
		FND_MESSAGE.SET_NAME('CS','CS_API_ALL_MISSING_PARAM');
		FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
		FND_MESSAGE.SET_TOKEN('MISSING_PARAM',p_param_name);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
END Check_Reqd_Param;


PROCEDURE Check_Reqd_Param
(
	p_var1          IN      VARCHAR2,
	p_param_name    IN      VARCHAR2,
	p_api_name      IN      VARCHAR2
) IS
BEGIN
	IF (NVL(p_var1,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR) THEN
		FND_MESSAGE.SET_NAME('CS','CS_API_ALL_MISSING_PARAM');
		FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
		FND_MESSAGE.SET_TOKEN('MISSING_PARAM',p_param_name);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
END Check_Reqd_Param;


PROCEDURE Check_Reqd_Param
(
	p_var1          IN      DATE,
	p_param_name    IN      VARCHAR2,
	p_api_name      IN      VARCHAR2
) IS
BEGIN
	IF (NVL(p_var1,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE) THEN
		FND_MESSAGE.SET_NAME('CS','CS_API_ALL_MISSING_PARAM');
		FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
		FND_MESSAGE.SET_TOKEN('MISSING_PARAM',p_param_name);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
END Check_Reqd_Param;

FUNCTION Is_StartEndDate_Valid
(
	p_st_dt                         IN      DATE,
	p_end_dt                        IN      DATE,
	p_stack_err_msg                 IN      BOOLEAN := TRUE
) RETURN BOOLEAN IS

	l_return_value BOOLEAN := TRUE;

BEGIN
	IF (p_st_dt > p_end_dt) THEN
		l_return_value := FALSE;
		IF ( p_stack_err_msg = TRUE ) THEN
		   FND_MESSAGE.SET_NAME('CS','CS_ALL_START_DATE_AFTER_END');
		   FND_MESSAGE.SET_TOKEN('START_DATE',p_st_dt);
		   FND_MESSAGE.SET_TOKEN('END_DATE',p_end_dt);
		   FND_MSG_PUB.Add;
		END IF;
	END IF;
	RETURN l_return_value;

END Is_StartEndDate_Valid;

FUNCTION Is_Flag_YorNorNull
(
	p_flag                  IN      VARCHAR2,
	p_stack_err_msg IN      BOOLEAN := TRUE
) RETURN BOOLEAN IS

	l_return_value BOOLEAN := TRUE;

BEGIN
	IF (p_flag NOT IN ('Y','N',NULL)) THEN
		l_return_value := FALSE;
		IF ( p_stack_err_msg = TRUE ) THEN
		   FND_MESSAGE.SET_NAME('CS','CS_API_INVALID_FLAG');
		   FND_MESSAGE.SET_TOKEN('FLAG',p_flag);
		   FND_MSG_PUB.Add;
		END IF;
	END IF;
	RETURN l_return_value;

END Is_Flag_YorNorNull;

PROCEDURE Add_Desc_Flex_Msg
  ( p_token_an	IN	VARCHAR2,
    p_token_dfm	IN	VARCHAR2 )
  IS
BEGIN
   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('CS', 'CS_API_SR_DESC_FLEX_ERROR');
      fnd_message.set_token('API_NAME', p_token_an);
      fnd_message.set_token('DESC_FLEX_MSG', p_token_dfm);
      fnd_msg_pub.add;
   END IF;
END Add_Desc_Flex_Msg;

PROCEDURE Is_DescFlex_Valid
(
	p_api_name			IN	VARCHAR2,
	p_appl_short_name		IN	VARCHAR2	:=	'CS',
	p_desc_flex_name		IN	VARCHAR2,
	p_seg_partial_name		IN	VARCHAR2,
	p_num_of_attributes		IN	NUMBER,
	p_seg_values			IN	DFF_Rec_Type,
	p_stack_err_msg		        IN	BOOLEAN	:=	TRUE
) IS

  p_desc_context	VARCHAR2(30);
  p_desc_col_name1	VARCHAR2(30)	:=	p_seg_partial_name||'1';
  p_desc_col_name2	VARCHAR2(30)	:=	p_seg_partial_name||'2';
  p_desc_col_name3	VARCHAR2(30)	:=	p_seg_partial_name||'3';
  p_desc_col_name4	VARCHAR2(30)	:=	p_seg_partial_name||'4';
  p_desc_col_name5	VARCHAR2(30)	:=	p_seg_partial_name||'5';
  p_desc_col_name6	VARCHAR2(30)	:=	p_seg_partial_name||'6';
  p_desc_col_name7	VARCHAR2(30)	:=	p_seg_partial_name||'7';
  p_desc_col_name8	VARCHAR2(30)	:=	p_seg_partial_name||'8';
  p_desc_col_name9	VARCHAR2(30)	:=	p_seg_partial_name||'9';
  p_desc_col_name10	VARCHAR2(30)	:=	p_seg_partial_name||'10';
  p_desc_col_name11	VARCHAR2(30)	:=	p_seg_partial_name||'11';
  p_desc_col_name12	VARCHAR2(30)	:=	p_seg_partial_name||'12';
  p_desc_col_name13	VARCHAR2(30)	:=	p_seg_partial_name||'13';
  p_desc_col_name14	VARCHAR2(30)	:=	p_seg_partial_name||'14';
  p_desc_col_name15	VARCHAR2(30)	:=	p_seg_partial_name||'15';
  l_return_status	VARCHAR2(1);
  l_resp_appl_id	NUMBER;
  l_resp_id		NUMBER;
  l_return_value	BOOLEAN		:=	TRUE;

BEGIN
	IF p_num_of_attributes > 15 THEN
		/* More than 15 attributes not currently supported. Please contact developer. */
		FND_MESSAGE.SET_NAME('CS','CS_API_NUM_OF_DESCFLEX_GT_MAX');
		FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

    Validate_Desc_Flex
    (
		p_api_name,
		p_appl_short_name,
      	p_desc_flex_name,
      	p_desc_col_name1,
      	p_desc_col_name2,
      	p_desc_col_name3,
      	p_desc_col_name4,
      	p_desc_col_name5,
      	p_desc_col_name6,
      	p_desc_col_name7,
      	p_desc_col_name8,
      	p_desc_col_name9,
      	p_desc_col_name10,
      	p_desc_col_name11,
      	p_desc_col_name12,
      	p_desc_col_name13,
      	p_desc_col_name14,
      	p_desc_col_name15,
      	p_seg_values.attribute1,
      	p_seg_values.attribute2,
      	p_seg_values.attribute3,
      	p_seg_values.attribute4,
      	p_seg_values.attribute5,
      	p_seg_values.attribute6,
      	p_seg_values.attribute7,
      	p_seg_values.attribute8,
      	p_seg_values.attribute9,
      	p_seg_values.attribute10,
      	p_seg_values.attribute11,
      	p_seg_values.attribute12,
      	p_seg_values.attribute13,
      	p_seg_values.attribute14,
      	p_seg_values.attribute15,
      	p_seg_values.context,
      	l_resp_appl_id,
      	l_resp_id,
      	l_return_status );

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		RAISE FND_API.G_EXC_ERROR;
	end if;
END Is_DescFlex_Valid;

------------------------------------------------------------------------------
--  Procedure	: Validate_Desc_Flex
------------------------------------------------------------------------------

PROCEDURE Validate_Desc_Flex
  ( p_api_name		IN	VARCHAR2,
    p_appl_short_name	IN	VARCHAR2 := 'CS',
    p_desc_flex_name	IN	VARCHAR2,
    p_column_name1	IN	VARCHAR2,
    p_column_name2	IN	VARCHAR2,
    p_column_name3	IN	VARCHAR2,
    p_column_name4	IN	VARCHAR2,
    p_column_name5	IN	VARCHAR2,
    p_column_name6	IN	VARCHAR2,
    p_column_name7	IN	VARCHAR2,
    p_column_name8	IN	VARCHAR2,
    p_column_name9	IN	VARCHAR2,
    p_column_name10	IN	VARCHAR2,
    p_column_name11	IN	VARCHAR2,
    p_column_name12	IN	VARCHAR2,
    p_column_name13	IN	VARCHAR2,
    p_column_name14	IN	VARCHAR2,
    p_column_name15	IN	VARCHAR2,
    p_column_value1	IN	VARCHAR2,
    p_column_value2	IN	VARCHAR2,
    p_column_value3	IN	VARCHAR2,
    p_column_value4	IN	VARCHAR2,
    p_column_value5	IN	VARCHAR2,
    p_column_value6	IN	VARCHAR2,
    p_column_value7	IN	VARCHAR2,
    p_column_value8	IN	VARCHAR2,
    p_column_value9	IN	VARCHAR2,
    p_column_value10	IN	VARCHAR2,
    p_column_value11	IN	VARCHAR2,
    p_column_value12	IN	VARCHAR2,
    p_column_value13	IN	VARCHAR2,
    p_column_value14	IN	VARCHAR2,
    p_column_value15	IN	VARCHAR2,
    p_context_value	IN	VARCHAR2,
    p_resp_appl_id	IN	NUMBER   := NULL,
    p_resp_id		IN	NUMBER   := NULL,
    x_return_status	OUT	NOCOPY VARCHAR2 )
  IS
     l_error_message	VARCHAR2(2000);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   fnd_flex_descval.set_column_value(p_column_name1, p_column_value1);
   fnd_flex_descval.set_column_value(p_column_name2, p_column_value2);
   fnd_flex_descval.set_column_value(p_column_name3, p_column_value3);
   fnd_flex_descval.set_column_value(p_column_name4, p_column_value4);
   fnd_flex_descval.set_column_value(p_column_name5, p_column_value5);
   fnd_flex_descval.set_column_value(p_column_name6, p_column_value6);
   fnd_flex_descval.set_column_value(p_column_name7, p_column_value7);
   fnd_flex_descval.set_column_value(p_column_name8, p_column_value8);
   fnd_flex_descval.set_column_value(p_column_name9, p_column_value9);
   fnd_flex_descval.set_column_value(p_column_name10, p_column_value10);
   fnd_flex_descval.set_column_value(p_column_name11, p_column_value11);
   fnd_flex_descval.set_column_value(p_column_name12, p_column_value12);
   fnd_flex_descval.set_column_value(p_column_name13, p_column_value13);
   fnd_flex_descval.set_column_value(p_column_name14, p_column_value14);
   fnd_flex_descval.set_column_value(p_column_name15, p_column_value15);
   fnd_flex_descval.set_context_value(p_context_value);
   IF NOT fnd_flex_descval.validate_desccols
     ( appl_short_name	=> p_appl_short_name,
       desc_flex_name	=> p_desc_flex_name,
       resp_appl_id	=> p_resp_appl_id,
       resp_id		=> p_resp_id ) THEN
      l_error_message := fnd_flex_descval.error_message;
      add_desc_flex_msg(p_api_name, l_error_message);
      x_return_status := fnd_api.g_ret_sts_error;
   END IF;
END Validate_Desc_Flex;

END CS_COUNTERS_EXT_PVT;

/
