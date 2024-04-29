--------------------------------------------------------
--  DDL for Package GL_CI_REMOTE_INVOKE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CI_REMOTE_INVOKE_PKG" AUTHID DEFINER as
/* $Header: glucirms.pls 120.7.12010000.2 2010/03/12 09:41:41 sommukhe ship $ */
  --+ a place to keep batch names
  type batch_record is RECORD (
    batch_name                gl_interface.reference1%TYPE,
    postable_rows             number,
    reqid                     number);
  type batch_table is table of batch_record index by binary_integer;
type coa_record is RECORD (
  segment_num               fnd_id_flex_segments.segment_num%TYPE,
  application_column_name   fnd_id_flex_segments.application_column_name%TYPE,
  display_size              fnd_id_flex_segments.display_size%TYPE);
type coa_table is table of coa_record index by binary_integer;
PROCEDURE drop_table(
         p_table_name       IN varchar2);
procedure coa_info (
    p_coa_id NUMBER,
    p_count  IN OUT NOCOPY Number);
procedure Get_Detail_coa_info (
    p_coa_id        IN NUMBER,
    p_count         IN Number,
    p_column_name   IN OUT NOCOPY varchar2,
    p_display_size  IN OUT NOCOPY number);
function Get_eMAIL_Address(
         p_user_name        IN varchar2) return varchar2;
function Get_User_ID(
         user_name          IN varchar2) return number;
function Get_Resp_ID(
         resp_name          IN varchar2) return number;
function Get_Ledger_Name(
         ledger_id             IN number) return varchar2;
function Get_Suspense_Flag(
         ledger_id             IN number) return varchar2;
function Get_Daily_Balance_Flag(
         ledger_id             IN number) return varchar2;
function Get_Cons_ledger_Flag(
         ledger_id             IN number) return varchar2;
function Get_Currency_Code(
         ledger_id             IN number) return varchar2;
function Get_COA_Id(
         ledger_id             IN number) return number;
function Period_Exists(
         ledger_id             IN number,
         period_name        IN varchar2) return number;
PROCEDURE Get_Target_Je_source_Name(
         p_adb_name         OUT NOCOPY varchar2,
         p_name             OUT NOCOPY varchar2);

PROCEDURE Get_Period_Info(
         ledger_id          IN number,
         period_name        IN varchar2,
         start_date         OUT NOCOPY varchar2,
         end_date           OUT NOCOPY varchar2,
         quarter_date       OUT NOCOPY varchar2,
         year_date          OUT NOCOPY varchar2);

procedure GLOBAL_INITIALIZE(
    user_id in number,
    resp_id in number,
    resp_appl_id in number,
    security_group_id in number default 0);

function Get_Login_Ids(
         p_user_name          IN varchar2,
         p_resp_name          IN varchar2,
         user_id            OUT NOCOPY number,
         resp_id            OUT NOCOPY number) return number;

function Validate_Resp(
         resp_name          IN varchar2) return number;

function Menu_Validation(
         user_id            IN number,
         resp_id            IN number,
         app_id             IN number,
         import_flag        IN varchar2,
         post_flag          IN varchar2) return varchar2;

function Get_Ledger_ID(
         p_user_id            IN number,
         p_resp_id            IN number,
         p_app_id             IN number,
         p_access_set_id      OUT NOCOPY number,
         p_access_set         OUT NOCOPY varchar2,
         p_access_code        OUT NOCOPY varchar2,
	 p_to_ledger_name     IN VARCHAR2) return number;

function Get_Budget_Version_ID(
         p_user_id            IN number,
         p_resp_id            IN number,
         p_app_id             IN number,
         p_budget_name        IN varchar2) return number;

function Apps_Initialize(
         user_id            IN number,
         resp_id            IN number,
         app_id             IN number,
         ledger_id          IN number,
         group_id           IN number,
         pd_name            IN varchar2,
         actual_flag        IN varchar2,
         avg_flag           IN varchar2)return number;
function Run_Journal_Import(
         user_id            IN number,
         resp_id            IN number,
         app_id             IN number,
         inter_run_id       IN number,
         ledger_id          IN number,
         csj_flag           IN VARCHAR2) return number;
PROCEDURE Verify_Journal_Import(
         p_group_id         IN number,
         result             OUT NOCOPY varchar2);
procedure Get_Postable_Rows(
         ledger_id          IN number,
         pd_name            IN varchar2,
         batch_id           IN number,
         status             IN varchar2,
         actual_flag        IN varchar2,
         avg_flag           IN varchar2,
         postable_rows      OUT NOCOPY number);
procedure Run_Journal_Post(
         user_id            IN number,
         resp_id            IN number,
         app_id             IN number,
         ledger_id          IN number,
         pd_name            IN varchar2,
         group_id           IN number,
         import_request_id  IN number,
         batch_id           IN number,
         actual_flag        IN varchar2,
         access_set_id      IN number,
         post_run_id        OUT NOCOPY number,
         reqid              OUT NOCOPY number);
PROCEDURE Verify_Journal_Post(
         l_pd_name          IN varchar2,
         postable_rows      IN number,
         l_ledger_id        IN number,
         l_batch_id         IN number,
         actual_flag        IN varchar2,
         avg_flag           IN varchar2,
         result             OUT NOCOPY varchar2);
procedure wait_for_request(
         request_id         IN number,
         result             OUT NOCOPY varchar2);
function get_request_status(
         request_id         IN number,
         result             OUT NOCOPY varchar2) return boolean;
procedure Test_run;

FUNCTION Get_Group_ID RETURN number;
procedure Create_Interface_Table(
         group_id           IN number,
         db_username        IN varchar2);

end GL_CI_REMOTE_INVOKE_PKG;

/
