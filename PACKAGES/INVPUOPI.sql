--------------------------------------------------------
--  DDL for Package INVPUOPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPUOPI" AUTHID CURRENT_USER AS
/* $Header: INVPUP1S.pls 120.1.12010000.2 2009/03/02 21:23:16 sanmani ship $ */

---Start:  Bug Fix 3051653
FUNCTION mtl_pr_parse_item_segments
(p_row_id      in            rowid
,item_number   out    NOCOPY VARCHAR2
,item_id       out    NOCOPY NUMBER
,err_text      out    NOCOPY varchar2
) RETURN INTEGER ;
---End: Bug Fix 3051653

--Start :New overloaded procedure mtl_pr_parse_item_number
PROCEDURE mtl_pr_parse_item_number(
   p_item_number     IN         VARCHAR2
  ,p_segment1        OUT NOCOPY VARCHAR2
  ,p_segment2        OUT NOCOPY VARCHAR2
  ,p_segment3        OUT NOCOPY VARCHAR2
  ,p_segment4        OUT NOCOPY VARCHAR2
  ,p_segment5        OUT NOCOPY VARCHAR2
  ,p_segment6        OUT NOCOPY VARCHAR2
  ,p_segment7        OUT NOCOPY VARCHAR2
  ,p_segment8        OUT NOCOPY VARCHAR2
  ,p_segment9        OUT NOCOPY VARCHAR2
  ,p_segment10       OUT NOCOPY VARCHAR2
  ,p_segment11       OUT NOCOPY VARCHAR2
  ,p_segment12       OUT NOCOPY VARCHAR2
  ,p_segment13       OUT NOCOPY VARCHAR2
  ,p_segment14       OUT NOCOPY VARCHAR2
  ,p_segment15       OUT NOCOPY VARCHAR2
  ,p_segment16       OUT NOCOPY VARCHAR2
  ,p_segment17       OUT NOCOPY VARCHAR2
  ,p_segment18       OUT NOCOPY VARCHAR2
  ,p_segment19       OUT NOCOPY VARCHAR2
  ,p_segment20       OUT NOCOPY VARCHAR2
  ,x_err_text        OUT NOCOPY VARCHAR2);
--End :New overloaded procedure mtl_pr_parse_item_number

FUNCTION mtl_pr_parse_item_number
(
item_number     varchar2,
item_id         number,
trans_id	number,
org_id          number,
err_text out	NOCOPY varchar2,
p_rowid         rowid
)
RETURN INTEGER;

FUNCTION mtl_pr_parse_flex_name
(
org_id		number,
flex_code	varchar2,
flex_name	varchar2,
flex_id in out	NOCOPY number,
set_id		number,
err_text out    NOCOPY varchar2,
structure_id number default -1 /*fix for bug 8288281*/
)
RETURN INTEGER;

function mtl_pr_trans_prod_item
(
item_number_in          varchar2,
org_id                  number,
item_id_out  out        NOCOPY number,
err_text     out	NOCOPY varchar2
)
RETURN INTEGER;

function mtl_pr_trans_org_id
(
org_code	varchar2,
org_id out	NOCOPY number,
err_text out    NOCOPY varchar2
)
RETURN INTEGER;

function mtl_pr_trans_template_id
(
templ_name	varchar2,
templ_id out 	NOCOPY number,
err_text out	NOCOPY varchar2
)
RETURN INTEGER;

FUNCTION mtl_log_interface_err
(
org_id		number,
user_id		number,
login_id        number,
prog_appid      number,
prog_id         number,
req_id      	number,
trans_id  	number,
error_text	varchar2,
p_column_name   VARCHAR2 := NULL,
tbl_name        varchar2,
msg_name        varchar2,
err_text       OUT  NOCOPY VARCHAR2
)
RETURN INTEGER;

FUNCTION mtl_pr_parse_item_name
(
item_number_in                  varchar2,
item_id_out  out       NOCOPY   number,
err_text     out       NOCOPY   varchar2
)RETURN INTEGER;


END INVPUOPI;

/
