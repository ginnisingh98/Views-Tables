--------------------------------------------------------
--  DDL for Package Body CZ_MANAGER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_MANAGER" as
/*  $Header: czmangrb.pls 115.12 2002/11/27 17:05:25 askhacha ship $	*/

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure ASSESS_DATA is
begin
CZ_XF_MGR.ASSESS_DATA;
CZ_IM_MGR.ASSESS_DATA;
CZ_PR_MGR.ASSESS_DATA;
CZ_PS_MGR.ASSESS_DATA;
CZ_QC_MGR.ASSESS_DATA;
CZ_OM_MGR.ASSESS_DATA;
CZ_LC_MGR.ASSESS_DATA;
CZ_GN_MGR.ASSESS_DATA;
CZ_UI_MGR.ASSESS_DATA;
CZ_PUB_MGR.ASSESS_DATA;
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure REDO_STATISTICS is
begin
CZ_PS_MGR.REDO_STATISTICS;
CZ_GN_MGR.REDO_STATISTICS;
CZ_PR_MGR.REDO_STATISTICS;
CZ_XF_MGR.REDO_STATISTICS;
CZ_IM_MGR.REDO_STATISTICS;
CZ_LC_MGR.REDO_STATISTICS;
CZ_UI_MGR.REDO_STATISTICS;
CZ_OM_MGR.REDO_STATISTICS;
CZ_QC_MGR.REDO_STATISTICS;
CZ_PUB_MGR.REDO_STATISTICS;
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure Triggers_Enabled
(Switch in varchar2) is
begin
CZ_PS_MGR.Triggers_Enabled(Switch);
CZ_GN_MGR.Triggers_Enabled(Switch);
CZ_PR_MGR.Triggers_Enabled(Switch);
CZ_XF_MGR.Triggers_Enabled(Switch);
CZ_IM_MGR.Triggers_Enabled(Switch);
CZ_LC_MGR.Triggers_Enabled(Switch);
CZ_UI_MGR.Triggers_Enabled(Switch);
CZ_OM_MGR.Triggers_Enabled(Switch);
CZ_QC_MGR.Triggers_Enabled(Switch);
CZ_PUB_MGR.Triggers_Enabled(Switch);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure CONSTRAINTS_ENABLED
(Switch in varchar2) is
begin
CZ_PS_MGR.Constraints_Enabled(Switch);
CZ_GN_MGR.Constraints_Enabled(Switch);
CZ_PR_MGR.Constraints_Enabled(Switch);
CZ_XF_MGR.Constraints_Enabled(Switch);
CZ_IM_MGR.Constraints_Enabled(Switch);
CZ_LC_MGR.Constraints_Enabled(Switch);
CZ_UI_MGR.Constraints_Enabled(Switch);
CZ_OM_MGR.Constraints_Enabled(Switch);
CZ_QC_MGR.Constraints_Enabled(Switch);
CZ_PUB_MGR.Constraints_Enabled(Switch);
end;


/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure REDO_SEQUENCES
(RedoStart_Flag in varchar2,
 incr           in integer default null) is
begin
CZ_UI_MGR.REDO_SEQUENCES(RedoStart_Flag,incr);
CZ_GN_MGR.REDO_SEQUENCES(RedoStart_Flag,incr);
CZ_IM_MGR.REDO_SEQUENCES(RedoStart_Flag,incr);
CZ_LC_MGR.REDO_SEQUENCES(RedoStart_Flag,incr);
CZ_XF_MGR.REDO_SEQUENCES(RedoStart_Flag,incr);
CZ_QC_MGR.REDO_SEQUENCES(RedoStart_Flag,incr);
CZ_PS_MGR.REDO_SEQUENCES(RedoStart_Flag,incr);
CZ_PR_MGR.REDO_SEQUENCES(RedoStart_Flag,incr);
CZ_OM_MGR.REDO_SEQUENCES(RedoStart_Flag,incr);
CZ_PUB_MGR.REDO_SEQUENCES(RedoStart_Flag,incr);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure PURGE is
begin
CZ_PUB_MGR.PURGE;
CZ_UI_MGR.PURGE;
CZ_PS_MGR.PURGE;
CZ_IM_MGR.PURGE;
CZ_LC_MGR.PURGE;
CZ_PR_MGR.PURGE;
CZ_OM_MGR.PURGE;
CZ_QC_MGR.PURGE;
CZ_XF_MGR.PURGE;
CZ_GN_MGR.PURGE;
CZ_PS_MGR.PURGE;
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE purge_cp(Errbuf IN OUT NOCOPY VARCHAR2,
		   Retcode IN OUT NOCOPY pls_integer) IS
BEGIN
   retcode := 0;
   purge;
EXCEPTION
   WHEN OTHERS THEN
      retcode := 2;
      errbuf := cz_utils.get_text('CZ_PURGE_FATAL_ERR', 'SQLERRM',Sqlerrm);
END purge_cp;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure RESET_CLEAR is
begin
CZ_IM_MGR.RESET_CLEAR;
CZ_PS_MGR.RESET_CLEAR;
CZ_UI_MGR.RESET_CLEAR;
CZ_LC_MGR.RESET_CLEAR;
CZ_PR_MGR.RESET_CLEAR;
CZ_OM_MGR.RESET_CLEAR;
CZ_QC_MGR.RESET_CLEAR;
CZ_XF_MGR.RESET_CLEAR;
CZ_GN_MGR.RESET_CLEAR;
CZ_PUB_MGR.RESET_CLEAR;
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

end;

/
