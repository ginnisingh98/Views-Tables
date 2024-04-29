--------------------------------------------------------
--  DDL for Package INVPOPIF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPOPIF" AUTHID CURRENT_USER AS
/* $Header: INVPOPIS.pls 120.5.12010000.2 2009/07/06 06:52:02 sisankar ship $ */

PROCEDURE inopinp_open_interface_process(
    ERRBUF           OUT NOCOPY VARCHAR2,
    RETCODE          OUT NOCOPY NUMBER,
    p_org_id          IN NUMBER,
    p_all_org         IN NUMBER      := 1,
    p_val_item_flag   IN NUMBER      := 1,
    p_pro_item_flag   IN NUMBER      := 1,
    p_del_rec_flag    IN NUMBER      := 1,
    p_xset_id         IN NUMBER  DEFAULT -999,
    p_run_mode        IN NUMBER  DEFAULT 1,
    p_gather_stats    IN NUMBER  DEFAULT 1,  /* Added for Bug 8532728 */
    source_org_id     IN NUMBER DEFAULT -999 /*Added for bug 6372595*/);

FUNCTION inopinp_open_interface_process
(
    org_id		NUMBER,
    all_org		NUMBER		:= 1,
    val_item_flag	NUMBER		:= 1,
    pro_item_flag	NUMBER		:= 1,
    del_rec_flag	NUMBER		:= 1,
    prog_appid		NUMBER		:= -1,
    prog_id		NUMBER		:= -1,
    request_id		NUMBER		:= -1,
    user_id		NUMBER		:= -1,
    login_id		NUMBER		:= -1,
    err_text     IN OUT	NOCOPY VARCHAR2,
    xset_id      IN     NUMBER       DEFAULT -999,
    default_flag IN NUMBER       DEFAULT 1,
    commit_flag  IN     NUMBER       	:= 1,
    run_mode     IN     NUMBER       	:= 1,
    source_org_id IN NUMBER DEFAULT -999,  /*Added for bug 6372595. Added functionality for looping over the master defaults assignment
					    when the import items program is called from the copy organization program*/
    gather_stats IN     NUMBER   DEFAULT 1 /* Added for Bug 8532728 */
)
RETURN INTEGER;

FUNCTION inopinp_OI_process_update (
    org_id		NUMBER,
    all_org		NUMBER		:= 1,
    val_item_flag	NUMBER		:= 1,
    pro_item_flag	NUMBER		:= 1,
    del_rec_flag	NUMBER		:= 1,
    prog_appid		NUMBER		:= -1,
    prog_id		NUMBER		:= -1,
    request_id		NUMBER		:= -1,
    user_id		NUMBER		:= -1,
    login_id		NUMBER		:= -1,
    err_text     IN OUT	NOCOPY VARCHAR2,
    xset_id      IN     NUMBER       DEFAULT -999,
    commit_flag  IN     NUMBER       DEFAULT 1,
    default_flag IN NUMBER  DEFAULT 1
)
    return INTEGER;

FUNCTION inopinp_OI_process_create (
    org_id		NUMBER,
    all_org		NUMBER		:= 1,
    val_item_flag	NUMBER		:= 1,
    pro_item_flag	NUMBER		:= 1,
    del_rec_flag	NUMBER		:= 1,
    prog_appid		NUMBER		:= -1,
    prog_id		NUMBER		:= -1,
    request_id		NUMBER		:= -1,
    user_id		NUMBER		:= -1,
    login_id		NUMBER		:= -1,
    err_text     IN OUT	NOCOPY VARCHAR2,
    xset_id      IN     NUMBER       DEFAULT -999,
    commit_flag  IN     NUMBER       DEFAULT 1,
    default_flag IN NUMBER  DEFAULT 1
)
    return INTEGER;

FUNCTION indelitm_delete_item_oi (
        err_text    OUT NOCOPY VARCHAR2,
        com_flag    IN     NUMBER       DEFAULT 1,
        xset_id     IN     NUMBER       DEFAULT -999

)
    return INTEGER;

g_source_org BOOLEAN := TRUE; /*Added for bug 6372595*/
END INVPOPIF;

/
