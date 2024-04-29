--------------------------------------------------------
--  DDL for Package CZ_DIAGNOSTICS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_DIAGNOSTICS_PVT" AUTHID CURRENT_USER AS
/*	$Header: czdiags.pls 120.1 2006/03/29 10:20:04 asiaston noship $		*/
---------------------------------------------------------------------------------------
DEFAULT_MARK_FIXED_CHAR   CONSTANT VARCHAR2(1)  := '7';
---------------------------------------------------------------------------------------
--This procedure traverses product structure and explosion in parallel, and reports the
--first encountered problem. It does not continue after the first problems because most
--errors in explosion will induce other errors, which would go away after the first one
--is corrected.
--
--p_debug_flag      if 1, writes the detailed message log to cz_db_logs, otherwise just
--                  returns one error message in the output parameter x_msg_data.
--
--x_return_status   FND_API.G_RET_STS_ERROR / FND_API.G_RET_STS_SUCCESS

PROCEDURE verify_structure(p_api_version     IN NUMBER,
                           p_devl_project_id IN NUMBER,
                           p_debug_flag      IN PLS_INTEGER,
                           x_run_id          IN OUT NOCOPY NUMBER,
                           x_return_status   IN OUT NOCOPY VARCHAR2,
                           x_msg_count       IN OUT NOCOPY NUMBER,
                           x_msg_data        IN OUT NOCOPY VARCHAR2);
---------------------------------------------------------------------------------------
--This procedure traverses product structure and explosion in parallel, and reports the
--first encountered problem. It does not continue after the first problems because most
--errors in explosion will induce other errors, which would go away after the first one
--is corrected.
--
--p_debug_flag      if 1, writes the detailed message log to cz_db_logs, otherwise just
--                  returns one error message in the output parameter x_msg_data.
--
--p_fix_extra_flag  in case when extra records are found the procedure can be requested
--                  to automatically delete them with this parameter set to 1.
--
--p_mark_fixed_char if deleting explosions, deleted_flag will be set to this character.
--
--x_return_status   FND_API.G_RET_STS_ERROR / FND_API.G_RET_STS_SUCCESS

PROCEDURE verify_structure(p_api_version     IN NUMBER,
                           p_devl_project_id IN NUMBER,
                           p_debug_flag      IN PLS_INTEGER,
                           p_fix_extra_flag  IN PLS_INTEGER,
                           p_mark_fixed_char IN VARCHAR2,
                           x_run_id          IN OUT NOCOPY NUMBER,
                           x_return_status   IN OUT NOCOPY VARCHAR2,
                           x_msg_count       IN OUT NOCOPY NUMBER,
                           x_msg_data        IN OUT NOCOPY VARCHAR2);
---------------------------------------------------------------------------------------
--Example if use:
--   SELECT cz_diagnostics_pvt.fast_verify(623160) FROM DUAL;

FUNCTION fast_verify(p_devl_project_id IN NUMBER) RETURN VARCHAR2;
---------------------------------------------------------------------------------------
--Example if use:
--   SET SERVEROUTPUT ON
--   BEGIN DBMS_OUTPUT.PUT_LINE(cz_diagnostics_pvt.fast_debug(623160)); END;
--   /
--   SELECT message FROM cz_db_logs WHERE run_id = <value> ORDER BY message_id;

FUNCTION fast_debug(p_devl_project_id IN NUMBER) RETURN NUMBER;
---------------------------------------------------------------------------------------
--This procedure can be used to automatically fix the explosions - it runs until the
--return status is successful. However, currently it can only delete extra explosion
--records, and has not been thoroughly tested. It is relatively safe, when the extra
--records is the only type of problem.
--
--It will mark the records it deletes with the character in p_mark_fixed_char, which
--must be specified. It is best if this character is not present in the deleted_flag
--before the run - this makes it easy to rollback the changes.
--
--Because the procedure may run many times, the debug output is disabled.
--
--Example of use: EXECUTE cz_diagnostics_pvt.fast_fix_extra(623160, '7');

PROCEDURE fast_fix_extra(p_devl_project_id IN NUMBER, p_mark_fixed_char IN VARCHAR2);
---------------------------------------------------------------------------------------
END;

 

/
