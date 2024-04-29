--------------------------------------------------------
--  DDL for Package Body GL_PA_AUTOALLOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_PA_AUTOALLOC_PKG" AS
/*  $Header: glalprjb.pls 120.2 2002/11/11 23:53:27 djogg ship $  */

FUNCTION GET_PERIOD_TYPE ( p_allocation_set_id In Number )
Return Varchar2 Is
l_period_type    Varchar2(2);
Begin

 l_period_type := PA_GL_AUTOALLOC_PKG.GET_PERIOD_TYPE(p_allocation_set_id);
 return(l_period_type);
End GET_PERIOD_TYPE;



FUNCTION Valid_Run_Period (  p_allocation_set_id   In 	Number,
			     p_pa_period           In	Varchar2
							DEFAULT  Null,
		             p_gl_period           In	Varchar2
							DEFAULT  Null)

Return BOOLEAN  Is
is_valid   Boolean;
Begin
  is_valid :=PA_GL_AUTOALLOC_PKG.Valid_Run_Period(p_allocation_set_id,
                                       p_pa_period,
                                       p_gl_period   );
  return(is_valid);

End Valid_Run_Period;

Function  Submit_Alloc_Request(	   p_rule_id         In	Number,
		            	   p_expnd_item_date In	Date,
				   p_pa_period       In	Varchar2,
				   p_gl_period       In	Varchar2
				     )
Return Number Is
  v_request_id	Number;
Begin
   v_request_id :=
      PA_GL_AUTOALLOC_PKG.Submit_Alloc_Request
                          ( p_rule_id,
			    p_expnd_item_date,
			    p_pa_period,
			    p_gl_period );

     Return v_request_id;
End Submit_Alloc_Request;

Procedure get_pa_step_status (
                      p_request_Id        In   Number
                     ,p_step_number       In   Number
                     ,p_mode              In   Varchar2
                     ,p_status            Out NOCOPY  Varchar2) IS
l_status      Varchar2(240);
Begin
       PA_GL_AUTOALLOC_PKG.get_pa_step_status
                        ( p_request_Id,
			  p_step_number,
			  p_mode,
			  l_status );

       p_status := l_status;

End get_pa_step_status;

Procedure upd_gl_autoalloc_batch_hist(
                     p_request_Id             In  Number
                    ,p_step_number            In  Number
                    ,p_pa_allocation_run_id   In  Number
                    ,p_return_code            Out NOCOPY Number ) Is
Begin

  Update GL_AUTO_ALLOC_BATCH_HISTORY
  Set pa_allocation_run_id = p_pa_allocation_run_id
  Where request_Id = p_request_Id
  And  step_number = p_step_number;

  If SQL%NOTFOUND Then
     p_return_code := -1;
  Else
   p_return_code := 0;
  End If;

End;

End GL_PA_AUTOALLOC_PKG;

/
