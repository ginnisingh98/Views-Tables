--------------------------------------------------------
--  DDL for Package Body PA_FIN_PLAN_TYPES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FIN_PLAN_TYPES_PUB" as
/* $Header: PAFTYPPB.pls 120.1 2005/08/19 16:32:22 mwasowic noship $ */

procedure delete
    (p_fin_plan_type_id               IN     pa_fin_plan_types_b.fin_plan_type_id%type,
     p_record_version_number          IN     pa_fin_plan_types_b.record_version_number%type,
     x_return_status       	      OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count           	      OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data		              OUT    NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895
 l_msg_count       NUMBER;
 l_msg_index_out   NUMBER;
 l_data            VARCHAR2(2000);
 l_msg_data        VARCHAR2(2000);
 l_return_status   VARCHAR2(2000);
begin

  /* Only the FIN_PLAN_TYPE_ID and RECORD_VERSION_NUMBER parameters are
     required for LOCK_ROW to work. Others are retained for the finplan
     types setup pages to work since the page is based on the _VL entity
     and OA expects the spec to comply to standards to work properly */

  Begin
    pa_fin_plan_types_pkg.lock_row
      (  X_FIN_PLAN_TYPE_ID => p_fin_plan_type_id,
         X_FIN_PLAN_TYPE_CODE => null,
         X_PRE_DEFINED_FLAG => null,
         X_GENERATED_FLAG => null,
         X_EDIT_GENERATED_AMT_FLAG => null,
         X_USED_IN_BILLING_FLAG => null,
         X_ENABLE_WF_FLAG => null,
         X_START_DATE_ACTIVE => null,
         X_END_DATE_ACTIVE => null,
         X_RECORD_VERSION_NUMBER => p_record_version_number,
         X_NAME => null,
         X_DESCRIPTION => null);
   Exception
     When Others Then
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_count     := 1;
       x_msg_data      := nvl(FND_MESSAGE.GET_ENCODED,SQLERRM);
       FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_TYPES_PUB',
                                p_procedure_name   => 'delete');
       RETURN;
   End;

   pa_fin_plan_types_utils.delete_val
       (  P_FIN_PLAN_TYPE_ID => p_fin_plan_type_id,
          X_RETURN_STATUS => x_return_status,
          X_MSG_COUNT => x_msg_count,
          X_MSG_DATA => x_msg_data);

   l_msg_count := FND_MSG_PUB.count_msg;

    if l_msg_count > 0 then
        if l_msg_count = 1 then
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data  := l_data;
             x_msg_count := l_msg_count;
        else
             x_msg_count := l_msg_count;
        end if;
        return;
    else
       pa_fin_plan_types_pkg.delete_row
         (  X_FIN_PLAN_TYPE_ID => p_fin_plan_type_id);

       DELETE
       FROM   pa_pt_co_impl_statuses
       WHERE  fin_plan_type_id=p_fin_plan_type_id;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

    end if;

Exception
    when OTHERS then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_TYPES_PUB',
                               p_procedure_name   => 'delete');
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
end delete;

END pa_fin_plan_types_pub;

/
