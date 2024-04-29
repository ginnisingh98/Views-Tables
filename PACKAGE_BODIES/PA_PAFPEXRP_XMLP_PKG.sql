--------------------------------------------------------
--  DDL for Package Body PA_PAFPEXRP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAFPEXRP_XMLP_PKG" AS
/* $Header: PAFPEXRPB.pls 120.1 2008/06/16 10:57:07 krreddy noship $ */
function cf_rejection_descriptionformul(rejection_code in varchar2) return char is
l_meaning varchar2(2000);
begin
    FND_MESSAGE.SET_NAME ('PA',rejection_code);
    l_meaning := FND_MESSAGE.GET;
    return(l_meaning);
exception when no_data_found then
          return(rejection_code);
end;
function BeforeReport return boolean is
l_org_fcst_period_type varchar2(30);
l_period_set_name varchar2(15);
l_act_period_type varchar2(15);
l_org_projfunc_currency_code varchar2(15);
l_number_of_periods number;
l_weighted_or_full_code varchar2(1);
l_org_proj_template_id number;
l_org_structure_version_id number;
l_fcst_start_date date;
l_fcst_end_date date;
l_org_id number;
l_return_status VARCHAR2(2000);
l_err_code VARCHAR2(2000);
l_dummy_name  varchar2(1000);
l_dummy_count  number;
begin

/*srw.user_exit('FND SRWINIT') ;*/null;
   /*srw.message(111,'Org Id = '||to_char(p_org_id));*/null;
   /*srw.message(111,'calling mo init');*/null;
   mo_global.init('PA');
   If  NVL(p_org_id,-99) = -99 Then
       /*srw.message(111, 'calling MO_GLOBAL.get_current_org_id');*/null;
       p_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID;
       /*srw.message(111, 'MO GLOBAL ORGID ='||p_org_id);*/null;
       If NVL(p_org_id,-99) = -99 Then
          /*srw.message(111,'Calling Get_Default OU');*/null;
          pa_moac_utils.GET_DEFAULT_OU
          (
           p_product_code       => 'PA'
          ,p_default_org_id    => p_org_id
          ,p_default_ou_name   => l_dummy_name
          ,p_ou_count          => l_dummy_count
          );
         /*srw.message(111,'Value of  orgid['||p_org_id||']');*/null;
       End If;
   End If;
   If p_org_id is NOT NULL Then
        /*srw.message(111,'Setting Single org context');*/null;
	MO_GLOBAL.set_policy_context('S',p_org_id);

   End If;
   p_start_organization_id_dummy:=p_start_organization_id;

  if p_organization_id IS NULL and p_start_organization_id_dummy IS NULL THEN
     /*srw.message(111, 'Getting start organization id from pa_imp');*/null;
     select start_organization_id into p_start_organization_id_dummy
       from pa_implementations;

  end if;
     /*srw.message(111, 'Calling pa_fp_org_fcst_utils.get_forecast_option_details');*/null;
        pa_fp_org_fcst_utils.get_forecast_option_details
        (  x_fcst_period_type           => l_org_fcst_period_type
          ,x_period_set_name            => l_period_set_name
          ,x_act_period_type            => l_act_period_type
          ,x_org_projfunc_currency_code => l_org_projfunc_currency_code
          ,x_number_of_periods          => l_number_of_periods
          ,x_weighted_or_full_code      => l_weighted_or_full_code
          ,x_org_proj_template_id       => l_org_proj_template_id
          ,x_org_structure_version_id   => p_org_structure_version_id
          ,x_fcst_start_date            => p_fcst_start_date
          ,x_fcst_end_date              => p_fcst_end_date
          ,x_org_id                     => p_org_id
          ,x_return_status              => l_return_status
          ,x_err_code                   => l_err_code);
            /*srw.message(1,': Forecast Options Data: ');*/null;
           /*srw.message(2,'l_org_fcst_period_type       ['||l_org_fcst_period_type||']');*/null;
           /*srw.message(3,'l_period_set_name            ['||l_period_set_name||']');*/null;
           /*srw.message(4,'l_act_period_type            ['||l_act_period_type||']');*/null;
           /*srw.message(5,'l_org_projfunc_currency_code ['||l_org_projfunc_currency_code||']');*/null;
           /*srw.message(6,'l_number_of_periods          ['||to_char(l_number_of_periods)||']');*/null;
           /*srw.message(7,'l_weighted_or_full_code      ['||l_weighted_or_full_code||']');*/null;
           /*srw.message(8,'l_org_proj_template_id       ['||to_char(l_org_proj_template_id)||']');*/null;
           /*srw.message(9,'l_org_structure_version_id   ['||to_char(p_org_structure_version_id)||']');*/null;
           /*srw.message(10,'p_fcst_start_date            ['||p_fcst_start_date||']');*/null;
           /*srw.message(11,'p_fcst_end_date              ['||p_fcst_end_date||']');*/null;
           /*srw.message(12,'l_org_id                     ['||to_char(p_org_id)||']');*/null;
          IF l_err_code IS NOT NULL THEN
             /*srw.message(13, ': Error occured while Getting forecast Options Det [' ||  l_err_code|| ']');*/null;
          END IF;
   p_project_id_parameter:=p_project_id;
   if p_project_id is NOT NULL THEN
        p_project_id_param := 'and fi.project_id =  '||p_project_id;
   else
        p_project_id_param := ' and fi.item_date between ('''||p_fcst_start_date||''') and  ('''||p_fcst_end_date||''')';
   end if;
  if p_assignment_id IS NOT NULL THEN
        p_assignment_id_param := 'and fi.assignment_id = '||p_assignment_id;
  else
        p_assignment_id_param := 'and 1 = 1';
  end if;
              /*srw.message(14,'p_project_id_param           ['||p_project_id_param||']');*/null;
              /*srw.message(15,'p_assignment_id_param        ['||p_assignment_id_param||']');*/null;
  return (TRUE);
end;
function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT') ;*/null;
  return (TRUE);
end;
--Functions to refer Oracle report placeholders--

function p_fcst_start_date_p return date is
begin
  return (p_fcst_start_date);
end;

function P_FCST_END_DATE_p return date is
begin
  return (P_FCST_END_DATE);
end;

function p_project_id_parameter_p return number is
begin
  return (p_project_id_parameter);
end;



END PA_PAFPEXRP_XMLP_PKG ;


/
