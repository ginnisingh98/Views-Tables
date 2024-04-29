--------------------------------------------------------
--  DDL for Package Body WIP_BIS_ALERTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_BIS_ALERTS" as
/* $Header: wipbialb.pls 120.1 2005/10/04 17:55:37 weizhou noship $ */

procedure post_actual_to_bis (
  trgt_short_name IN VARCHAR2,
  period_set_name IN VARCHAR2,
  period_name     IN VARCHAR2,
  org_id          IN NUMBER,
  actual          IN NUMBER) IS
BEGIN
  return;
END post_actual_to_bis;

procedure get_last_comp_period (
  func              IN VARCHAR2,
  prd_set_name      IN VARCHAR2,
  prd_type          IN VARCHAR2,
  prd_name          OUT NOCOPY VARCHAR2,
  prd_start_date    OUT NOCOPY DATE,
  prd_end_date      OUT NOCOPY DATE) IS
begin
  return;
end get_last_comp_period;

procedure get_actual(
  func          IN VARCHAR2,
  prd_set_name  IN VARCHAR2,
  prd_name      IN VARCHAR2,
  org_id        IN NUMBER,
  actual        OUT NOCOPY NUMBER) IS
begin
  return;
end get_actual;

procedure get_target(
  trgt_table         IN VARCHAR2,
  prd_set_name       IN VARCHAR2,
  prd_name           IN VARCHAR2,
  org_id             IN  NUMBER,
  target             OUT NOCOPY NUMBER,
  l_wf_process       OUT NOCOPY VARCHAR2,
  l_role             OUT NOCOPY VARCHAR2,
  l_role_id          OUT NOCOPY NUMBER) IS
begin
  return;
end get_target;

procedure alert_check(func IN VARCHAR2) IS
begin
  return;
end alert_check;

procedure WIP_Strt_Wf_Process (
   p_subject           Varchar2
   ,p_period            Varchar2
   ,p_legal_entity      Varchar2
   ,p_org               Varchar2
   ,p_wf_process        Varchar2
   ,p_role              Varchar2
   ,p_actual            Varchar2
   ,p_target            Varchar2
   ,p_report_name1      Varchar2
   ,p_report_param1     Varchar2
   ,p_responsibility_id NUMBER
   ,x_return_status     OUT NOCOPY Varchar2) IS
Begin
  return;
end WIP_Strt_Wf_Process;

end WIP_BIS_ALERTS;

/
