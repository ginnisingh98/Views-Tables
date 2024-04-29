--------------------------------------------------------
--  DDL for Package Body GMS_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_UTILITY" AS
/* $Header: gmsutilb.pls 120.3 2006/02/09 00:07:39 rshaik noship $ */

Function GET_AWARD_NUMBER(P_Award_Id    IN NUMBER) RETURN VARCHAR2 IS

x_sql VARCHAR2(2000);
cur_select INTEGER;
X_Award_Number VARCHAR2(30);
X_Rows_Processed NUMBER;

 Begin

  X_sql :=        'Select award_number '
 		||' from gms_awards where '
                ||' award_id = :Award_Id ';

  cur_select := DBMS_SQL.OPEN_CURSOR;



  DBMS_SQL.PARSE(cur_select,X_sql,dbms_sql.native);

  DBMS_SQL.BIND_VARIABLE(cur_select,':Award_Id', P_Award_Id);

  DBMS_SQL.DEFINE_COLUMN(cur_select, 1 , X_Award_Number, 15);

   X_Rows_Processed := DBMS_SQL.EXECUTE(cur_select);


  If DBMS_SQL.FETCH_ROWS(cur_select) > 0 then

     DBMS_SQL.COLUMN_VALUE(cur_select,1 , X_Award_Number);
  End If;


      RETURN X_Award_Number;


End GET_AWARD_NUMBER;

-------------------------------------------------------------------------------

procedure gms_util_fck (x_sob_id                IN NUMBER,
                        x_packet_id             IN NUMBER,
                        x_fcmode                IN VARCHAR2 DEFAULT 'C',
                        x_override              IN BOOLEAN,
                        x_partial               IN VARCHAR2 DEFAULT 'N',
                        x_user_id               IN NUMBER DEFAULT NULL,
                        x_user_resp_id          IN NUMBER DEFAULT NULL,
                        x_execute               IN VARCHAR2 DEFAULT 'N',
                        x_gms_return_code       IN OUT NOCOPY VARCHAR2,
                        x_gl_return_code        IN OUT NOCOPY VARCHAR2
                       ) IS

   x_gms_user_id         varchar2(20) ;
   x_uid                 varchar2(20) ;
   x_uir_id              varchar2(20) ;
   x_gms_user_resp_id    varchar2(20) ;
   x_gms_packet_id       varchar2(20) ;
   x_gms_sob_id          varchar2(20) ;
   x_flag                varchar2(1) := 'N' ;
   x_override_flag       VARCHAR2(1);

   x_gms_e_code            VARCHAR2(1);
   x_gms_e_stage           VARCHAR2(2000);

   l_gms_return_code	   varchar2(30) ;
   l_gl_return_code	   varchar2(30) ;

   cursor_name           INTEGER;
   fck_processed         INTEGER;
   proc_stat             VARCHAR2(1000);
   ret                   boolean;
   status                varchar2(30);
   industry              varchar2(30);

  x_error_message VARCHAR2(240);

BEGIN

  ret := fnd_installation.get(8402, 8402, status, industry);
  if (status = 'I' ) then
  if (x_override) then
      x_override_flag := 'Y';
    else
      x_override_flag := 'N';
  end if;
  l_gms_return_code	:= x_gms_return_code ;
  l_gl_return_code	:= x_gl_return_code ;

  cursor_name := dbms_sql.open_cursor;


  proc_stat := 'declare gms_code_local VARCHAR2(1); '||
               ' gms_e_code VARCHAR2(1); gl_code_local VARCHAR2(1); gms_e_stage VARCHAR2(1000); '||
               ' begin if not gms_funds_control_pkg.gms_fck(' ||
                ':GMS_SOB_ID, :GMS_PACKET_ID, :GMS_MODE,'||
                ':GMS_OVERRIDE_FLAG, :GMS_PARTIAL,'||
		':GMS_USER_ID, :GMS_USER_RESP_ID,:GMS_FLAG,'||
                ':GMS_CODE_LOCAL'||','||
                ':GMS_E_CODE'||','||
                ':GMS_E_STAGE'||') then '||
                'update gl_bc_packets '||
                'set status_code = ''T'''||
                ' where packet_id = :GMS_PACKET_ID '||'; '||
                'commit; '||
                'end if; end;';


 x_error_message := 'Error in PARSE ';
 dbms_sql.parse(cursor_name,proc_stat,dbms_sql.native);


 x_error_message := 'Error in BIND ';
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_CODE_LOCAL', 'X', 1);
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_E_CODE', 'E_X' ,10 );
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_E_STAGE', 'E_STG', 1000);
   x_gms_sob_id         := to_char(x_sob_id) ;
   x_gms_packet_id      := to_char(x_packet_id) ;
   x_uid           	:= to_char(x_user_id) ;
   x_uir_id        	:= to_char(x_user_resp_id) ;
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_SOB_ID',x_gms_sob_id,20) ;
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_PACKET_ID',x_gms_packet_id,20) ;
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_MODE',x_fcmode,2) ;
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_OVERRIDE_FLAG',x_override_flag,2) ;
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_FLAG',x_flag,2) ;
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_PARTIAL',x_partial,2) ;
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_USER_ID',x_uid,20) ;
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_USER_RESP_ID',x_uir_id,20) ;


 fck_processed := dbms_sql.execute(cursor_name);

 DBMS_SQL.VARIABLE_VALUE(cursor_name,':GMS_CODE_LOCAL', L_gms_return_code);
 DBMS_SQL.VARIABLE_VALUE(cursor_name,':GMS_E_CODE', X_gms_e_code);
 DBMS_SQL.VARIABLE_VALUE(cursor_name,':GMS_E_STAGE',X_gms_e_stage);

 dbms_sql.close_cursor(cursor_name);
   if l_gms_return_code in ('F','T') then
      if l_gms_return_code in ('F') then
         update gl_bc_packets gl
                set gl.status_code = 'R'
         where gl.packet_id = x_packet_id;
      end if;
      if l_gms_return_code in ('T') then
         update gl_bc_packets gl
                set gl.status_code = 'T'
         where gl.packet_id = x_packet_id;
      end if;
      l_gl_return_code := 'F';
      commit;
   end if;
 end if; -- status

 X_gms_return_code	:= L_gms_return_code ;
 X_gl_return_code	:= l_gl_return_code ;

EXCEPTION
 WHEN OTHERS THEN
      dbms_sql.close_cursor(cursor_name);
      X_gms_return_code	:= L_gms_return_code ;
      X_gl_return_code	:= l_gl_return_code ;

end gms_util_fck;

--------------------------------------------------------------------------------------
--
-- BUG: 3523587 GMS funds checking integrations with AP autonomus funds checking.
-- ISSUE : gms funds control package synchronize the award distribution lines.
--         with autonomus funds checking ap distribution lines are not available or
--         not available to update award set id back to ap distribution lines.
--
-- RESOLUTION :
--         Create award distribution lines with the same award set id but higher
--         distribution line number. This is done before gms funds checking.
--         After gms funds checking award distribution lines with hight line
--         numbers are deleted.
--
--  R12 Fundscheck Management uptake: In R12, AP/PO/REQ will no longer be saving
--  data before calling fundscheck and fundscheck logic of accessing AP/PO/REQ
--  is modified.With new architecture REMOVE_DUPLICATE_ADLS and
--  CREATE_DUPLICATE_ADLS are obsolete as these scenarios will no more be reproducible.
--------------------------------------------------------------------------------------
-- BUG: 3517362 forward port funds check related changes.
-- Obsoleted PROCEDURE REMOVE_DUPLICATE_ADLS( p_packet_id IN NUMBER )
-- Obsoleted PROCEDURE CREATE_DUPLICATE_ADLS( p_packet_id IN NUMBER )
--------------------------------------------------------------------------------------
procedure gms_util_pc_fck (x_sob_id                IN NUMBER,
                        x_packet_id                IN NUMBER,
                        x_fcmode                   IN VARCHAR2 DEFAULT 'C',
                        x_override                 IN VARCHAR2 DEFAULT 'N',
                        x_partial                  IN VARCHAR2 DEFAULT 'N',
                        x_user_id                  IN NUMBER DEFAULT NULL,
                        x_user_resp_id             IN NUMBER DEFAULT NULL,
                        x_execute                  IN VARCHAR2 DEFAULT 'N',
                        x_gms_return_code          IN OUT NOCOPY VARCHAR2
                       ) IS


   x_gms_e_code            VARCHAR2(1);
   x_gms_e_stage           VARCHAR2(2000);
   cursor_name           INTEGER;
   fck_processed         INTEGER;
   proc_stat             VARCHAR2(1000);

   x_flag                varchar2(1) := 'N' ;
   x_gms_sob_id          varchar2(20) ;
   x_gms_packet_id       varchar2(20) ;
   x_uid                 varchar2(20) ;
   x_uir_id              varchar2(20) ;


   ret                   boolean;
   status                varchar2(30);
   industry              varchar2(30);

  x_error_message VARCHAR2(240);
  l_mode		varchar2(1) ;
  l_gms_return_code	varchar2(3) ;

BEGIN

  l_gms_return_code	:= x_gms_return_code ;

  ret := fnd_installation.get(8402, 8402, status, industry);
  if (status = 'I' ) then

   		------------------------------------------------------		--1472633
                --For mode coming from PO,REQ
                ------------------------------------------------------
                if x_fcmode in ('A','F') then
                        l_mode := 'R';
                else
                        l_mode := x_fcmode;
                end if;
                ------------------------------------------------------
  cursor_name := dbms_sql.open_cursor;


  proc_stat := 'declare gms_code_local VARCHAR2(1); '||
               ' gms_e_code VARCHAR2(1); gms_e_stage VARCHAR2(1000); '||
               ' begin if not gms_funds_control_pkg.gms_fck(' ||
	       ':GMS_SOB_ID, :GMS_PACKET_ID, :GMS_FCMODE,'||
	       ':GMS_OVERRIDE,:GMS_PARTIAL,'||
	       ':GMS_USER_ID, :GMS_USER_RESP_ID, :GMS_FLAG,'||
                ':GMS_CODE_LOCAL'||','||
                ':GMS_E_CODE'||','||
                ':GMS_E_STAGE'||') then '||
                ':gms_code_local := ''T''; '||
                'end if; end;';


 x_error_message := 'Error in PARSE ';
 dbms_sql.parse(cursor_name,proc_stat,dbms_sql.native);

  --
  -- BUG 3523587
  -- GMS funds checking integrations with ap autonomous funds checking code.
  --
  -- BUG: 3517362 forward port funds check related changes.
  --  R12 Fundscheck Management uptake: obsoleted procedure call
  -- create_duplicate_adls(x_packet_id) ;

 x_error_message := 'Error in BIND ';
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_CODE_LOCAL', 'X', 1);
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_E_CODE', 'E_X' ,10 );
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_E_STAGE', 'E_STG', 1000);
   x_gms_sob_id := to_char(x_sob_id) ;
   x_gms_packet_id := to_char(x_packet_id) ;
   x_uid           := to_char(x_user_id) ;
   x_uir_id        := to_char(x_user_resp_id) ;
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_SOB_ID',x_gms_sob_id,20);
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_PACKET_ID',x_gms_packet_id,20) ;
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_FCMODE',l_mode,2) ;
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_OVERRIDE',x_OVERRIDE,2) ;
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_FLAG',x_flag,2) ;
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_PARTIAL',x_partial,2) ;
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_USER_ID',x_uid,20) ;
   DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_USER_RESP_ID',x_uir_id,20) ;

 fck_processed := dbms_sql.execute(cursor_name);

 DBMS_SQL.VARIABLE_VALUE(cursor_name,':GMS_CODE_LOCAL', l_gms_return_code);
 DBMS_SQL.VARIABLE_VALUE(cursor_name,':GMS_E_CODE', X_gms_e_code);
 DBMS_SQL.VARIABLE_VALUE(cursor_name,':GMS_E_STAGE',X_gms_e_stage);



 dbms_sql.close_cursor(cursor_name);
  --
  -- BUG 3523587
  -- GMS funds checking integrations with ap autonomous funds checking code.
  --
  -- BUG: 3517362 forward port funds check related changes.
  --  R12 Fundscheck Management uptake: obsoleted procedure call
  --remove_duplicate_adls(x_packet_id) ;
 COMMIT ;
 end if; -- status

 x_gms_return_code := l_gms_return_code ;

EXCEPTION
 WHEN OTHERS THEN
      l_gms_return_code := 'T';
      dbms_sql.close_cursor(cursor_name);

      l_gms_return_code := 'T';

      x_gms_e_stage := substr('gms_utility.gms_util_pc_fck:'||SQLCODE||':'||SQLERRM,1,2000);

       -- Bug 3416571
       -- Comment out ,fc_error_message to resolve 1153 compatibility.
       -- bug 3425948 uncomment out fc_error_message
      update gms_bc_packets
      set    status_code = 'T' ,
	     result_code = 'F89' , fc_error_message = x_gms_e_stage
      where  packet_id   = x_packet_id;

      If l_mode = 'C' then

         delete gms_bc_packet_arrival_order
         where  packet_id = x_packet_id;

      End if;
      x_gms_return_code := l_gms_return_code ;
      UPDATE gl_bc_packets SET
             result_code = DECODE (NVL (SUBSTR (result_code, 1, 1), 'P'),'P', 'F71',result_code)
       WHERE packet_id = x_packet_id;

       --
       -- BUG 3523587
       -- GMS funds checking integrations with ap autonomous funds checking code.
       --
       --  R12 Fundscheck Management uptake: obsoleted procedure call
       --remove_duplicate_adls(x_packet_id) ;
       COMMIT ;
end gms_util_pc_fck;
------------------------------------------------------------------------------------------------

procedure gms_util_gl_return_code(x_packet_id         IN NUMBER,
			          x_mode              IN VARCHAR2,
                                  x_gl_return_code    IN OUT NOCOPY VARCHAR2,
                                  x_gms_return_code   IN VARCHAR2,
                                  x_partial_resv_flag IN VARCHAR2
                                  ) IS


   gms_e_code            VARCHAR2(1);
   gms_e_stage           VARCHAR2(2000);
   cursor_name           INTEGER;
   stat_processed        INTEGER;
   proc_stat             VARCHAR2(1000);
   x_gms_packet_id	     varchar2(20) ;
   ret                   boolean;
   status                varchar2(30);
   industry              varchar2(30);
   l_mode                varchar2(1) ;
   l_gl_return_code	 varchar2(1) ;
   l_new_api             varchar2(1) ;

   CURSOR c_new_api IS
      SELECT 'Y'
        FROM dual
       WHERE EXISTS ( SELECT 1
                        FROM gl_bc_packets gl_pkt
                       WHERE gl_pkt.packet_id = x_packet_id
                         AND gl_pkt.template_id is NULL
                         AND exists (select 1
                                       from gms_bc_packets gms_pkt
                                      where gms_pkt.packet_id = x_packet_id
                                        AND gms_pkt.document_type IN ('AP','PO','REQ')
                                        AND gms_pkt.source_event_id = gl_pkt.event_id )
                    ) ;

BEGIN

  l_gl_return_code := x_gl_return_code ; -- Bug 3017422 : Passed the correct parameter
  ret := fnd_installation.get(8402, 8402, status, industry);

   IF (status = 'I' ) then

        -- =====================================================
        -- BUG: 3416573
        -- GMS_GL_RETURN_CODE API for autonomous funds checking.
        -- =====================================================
	l_new_api := 'N' ;
        OPEN  c_new_api ;
        FETCH c_new_api into l_new_api ;
        CLOSE c_new_api ;

	------------------------------------------------------
        --For mode coming from PO,REQ
        ------------------------------------------------------
        l_mode := x_mode;
        if x_mode in ('A','F') then
           l_mode := 'R';
        end if;

        -- ========================================================
        -- BUG: 3416573
        -- GMS_GL_RETURN_CODE API for autonomous funds checking.
	-- Call gms_funds_posting_pkg.gms_gl_return_code for
	-- Requisition,PO and AP. The new api was added to resolve
	-- the commit issue in gms_gl_return_code.
        -- =========================================================
        -- BUG: 3517362 forward port funds check related changes.
        IF NVL(l_new_api,'N') = 'Y'  THEN
           proc_stat := ' declare x_gl_return_code_local  varchar2(1);
                               gms_e_code varchar2(1);
                               gms_e_stage varchar2(1000);  '||
                        'begin
                           gms_funds_posting_pkg.gms_gl_return_code('||
		                   ':gms_e_code,:gms_e_stage,:x_gl_return_code_local,
                                    :GMS_PACKET_ID,:GMS_mode,
                                    :GMS_RETURN_CODE,'||
		                   ':GMS_PARTIAL_RESV_FLAG);
                         end;';
	ELSE
           proc_stat := ' declare x_gl_return_code_local  varchar2(1);
                                  gms_e_code varchar2(1);
                                  gms_e_stage varchar2(1000);  '||
                         'begin
                              gms_funds_control_pkg.gms_gl_return_code('||
		                      ':GMS_PACKET_ID,:GMS_mode, :x_gl_return_code_local, :GMS_RETURN_CODE,'||
		                      ':GMS_PARTIAL_RESV_FLAG,'||
                              ':gms_e_code,:gms_e_stage);
                          end;';

        END IF ;

        cursor_name := dbms_sql.open_cursor;
        dbms_sql.parse(cursor_name,proc_stat,dbms_sql.native);
        x_gms_packet_id  := to_char(x_packet_id) ;
        DBMS_SQL.BIND_VARIABLE(cursor_name,':x_gl_return_code_local', l_gl_return_code, 1);
        DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_PACKET_ID', x_gms_packet_id, 20);
        DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_MODE', l_MODE, 2);
        DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_RETURN_CODE', x_gms_return_code, 2);
        DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_PARTIAL_RESV_FLAG', x_partial_resv_flag, 2);
        DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_E_CODE', 'E_X' ,10 );
        DBMS_SQL.BIND_VARIABLE(cursor_name,':GMS_E_STAGE', 'E_STG', 1000);
        stat_processed := dbms_sql.execute(cursor_name);
        DBMS_SQL.VARIABLE_VALUE(cursor_name,':x_gl_return_code_local', l_gl_return_code);
        dbms_sql.close_cursor(cursor_name);
  end if;
  x_gl_return_code	:= l_gl_return_code ;

EXCEPTION
 WHEN OTHERS THEN
      dbms_sql.close_cursor(cursor_name);

      l_gl_return_code := 'Z';

      gms_e_stage := substr('gms_utility.gms_util_gl_return_code:'||SQLCODE||':'||SQLERRM,1,2000);

      -- Bug : 2557041 - Changed F00 to F71 , F00 was a generic code, F71 result code is for unexpected error

      UPDATE gl_bc_packets gl
         SET gl.result_code = DECODE ( NVL (SUBSTR (result_code, 1, 1), 'P'),
                                       'P', 'F71',result_code
				     )
       WHERE gl.packet_id = x_packet_id;

       -- Bug 3416571
       -- Comment out ,fc_error_message to resolve 1153 compatibility.
       --
       UPDATE gms_bc_packets gms
          SET gms.status_code = 'T',
              gms.result_code = DECODE (NVL (SUBSTR (result_code, 1, 1), 'P'),
                                     'P', 'F68',result_code)
              ,fc_error_message = gms_e_stage
        WHERE gms.packet_id = x_packet_id;

        x_gl_return_code	:= l_gl_return_code ;

END gms_util_gl_return_code;

END GMS_UTILITY ;

/
