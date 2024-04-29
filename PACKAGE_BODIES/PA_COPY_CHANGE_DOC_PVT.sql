--------------------------------------------------------
--  DDL for Package Body PA_COPY_CHANGE_DOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COPY_CHANGE_DOC_PVT" AS
--$Header: PACICCDB.pls 120.6.12010000.7 2010/05/06 12:02:33 rrambati noship $

G_EXCEPTION_ERROR		EXCEPTION;
G_EXCEPTION_UNEXPECTED_ERROR	EXCEPTION;

procedure COPY_CONTROL_ITEM(
         p_ci_id                IN     NUMBER
        ,p_ci_number            IN     VARCHAR2
        ,p_version_number       IN     NUMBER
        ,p_version_comments     IN     VARCHAR2
        ,x_ci_id                OUT    NOCOPY NUMBER
        ,x_version_number       OUT    NOCOPY NUMBER

        ,x_return_status        OUT    NOCOPY VARCHAR2
        ,x_msg_count            OUT    NOCOPY NUMBER
        ,x_msg_data             OUT    NOCOPY VARCHAR2
) IS
  l_reason      NUMBER := NULL; -- mwxx VARCHAR2(30):= NULL;
   l_class_code  NUMBER := NULL; -- mwxx VARCHAR2(30):= NULL;
   p_reason      NUMBER := NULL; -- mwxx VARCHAR2(30):= NULL;
   p_class_code  NUMBER := NULL; -- mwxx VARCHAR2(30):= NULL;
   l_msg_index_out        NUMBER;
   l_from_type_id         NUMBER;
   l_relationship_id      NUMBER;
   l_commit          VARCHAR2(1) := 'N';
   l_old_supp_yn          VARCHAR2(1) := 'N';
   copy_from_row          pa_control_items%ROWTYPE;

   l_action_id number := null;

   x_error_msg_code       varchar2(100) := NULL;

   l_ci_id number := null;
   l_ci_number pa_control_items.ci_number%type := p_ci_number;
   l_version_comments pa_control_items.version_comments%type := p_version_comments;
   lx_ci_id number := null;
   x_ci_number pa_control_items.ci_number%type := null;
   l_audt_hist_num number := 0;

   x_supp_rowid    varchar2(50) := null;
   x_supp_ci_transaction_id number := null;

   x_budget_vers_rowid    varchar2(50) := null;
   x_budget_vers_id number := null;
   l_budget_vers_id number := null;
   l_row_id rowid := null;
   l_relationship_type VARCHAR2(30) := 'CI_INCLUDED_ITEM'; --- relationship type for included items
   x_relationship_id number := NULL;

   CURSOR c_from_item
	is
	   SELECT * FROM pa_control_items
	   WHERE ci_id = p_ci_id;

   CURSOR c_action_from
	is
	   select * from  PA_CI_ACTIONS
	   WHERE ci_id = p_ci_id;

   CURSOR c_obj_id_to1
	is
	   select object_id_to1 from  pa_object_relationships
	   WHERE object_id_from1 = p_ci_id;

   CURSOR c_comments_from(p_action_id number)
	is
	   select * from  PA_CI_COMMENTS
	   WHERE ci_id = p_ci_id
           AND nvl(ci_action_id,-999)=p_action_id;

   CURSOR c_comments_from1
	is
	   select * from  PA_CI_COMMENTS
	   WHERE ci_id = p_ci_id
           AND ci_action_id is null;

   CURSOR c_supp_dtls_from
	is
	   select * from  PA_CI_SUPPLIER_DETAILS
	   WHERE ci_id = p_ci_id;

   CURSOR c_budget_vers_from
	is
	   select * from  PA_BUDGET_VERSIONS
	   WHERE ci_id = p_ci_id;

   cursor c_vers_num
        is
          select max(nvl(version_number,0))
          from PA_CONTROL_ITEMS
          where ci_id = p_ci_id;

   cursor c_old_supp
        is
          select 'Y'
          from pa_ci_impact_type_usage Usg,
               pa_control_items ci
          where usg.ci_type_id = ci.ci_type_id
          and ci.ci_id = p_ci_id
          and usg.impact_type_code = 'SUPPLIER';

begin

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_COPY_CHANGE_DOC_PVT.COPY_CONTROL_ITEM');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  /*
    IF p_commit = FND_API.g_true THEN
    SAVEPOINT COPY_CONTROL_ITEM;
  END IF;
*/

  OPEN c_from_item;
  FETCH c_from_item INTO copy_from_row;
  if c_from_item%NOTFOUND then
       close c_from_item;
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_CI_NO_FROM_ITEM');
       x_return_status := FND_API.G_RET_STS_ERROR;
  end if;
  close c_from_item;

      PA_CONTROL_ITEMS_PKG.INSERT_ROW (
         copy_from_row.ci_type_id
        ,copy_from_row.summary
        ,copy_from_row.status_code
        ,copy_from_row.owner_id
        ,copy_from_row.highlighted_flag
        ,NVL(copy_from_row.progress_status_code, 'PROGRESS_STAT_ON_TRACK')
        ,NVL(copy_from_row.progress_as_of_date,sysdate)
        ,copy_from_row.classification_code_id
        ,copy_from_row.reason_code_id
        ,copy_from_row.project_id
       -- ,sysdate
        ,copy_from_row.last_modified_by_id
        ,copy_from_row.object_type
        ,copy_from_row.object_id
        ,l_ci_number
        ,copy_from_row.date_required
        ,copy_from_row.date_closed
        ,copy_from_row.closed_by_id
        ,copy_from_row.description
        ,copy_from_row.status_overview
        ,copy_from_row.resolution
        ,copy_from_row.resolution_code_id
        ,copy_from_row.priority_code
        ,copy_from_row.effort_level_code
        ,nvl(copy_from_row.open_action_num,0)
        ,copy_from_row.price
        ,copy_from_row.price_currency_code
        ,copy_from_row.source_type_code
        ,copy_from_row.source_comment
        ,copy_from_row.source_number
        ,copy_from_row.source_date_received
        ,copy_from_row.source_organization
        ,copy_from_row.source_person

        ,copy_from_row.attribute_category

        ,copy_from_row.attribute1
        ,copy_from_row.attribute2
        ,copy_from_row.attribute3
        ,copy_from_row.attribute4
        ,copy_from_row.attribute5
        ,copy_from_row.attribute6
        ,copy_from_row.attribute7
        ,copy_from_row.attribute8
        ,copy_from_row.attribute9
        ,copy_from_row.attribute10
        ,copy_from_row.attribute11
        ,copy_from_row.attribute12
        ,copy_from_row.attribute13
        ,copy_from_row.attribute14
        ,copy_from_row.attribute15
        ,copy_from_row.PCO_STATUS_CODE
        ,copy_from_row.APPROVAL_TYPE_CODE
        ,'N' -- locked flag
        ,p_version_number
        ,'Y'
        ,l_Version_Comments
        ,copy_from_row.Original_ci_id
        ,p_ci_id -- source ci id
        ,lx_ci_id
        ,x_return_status
        ,x_msg_count
        ,x_msg_data
        ,copy_from_row.orig_system_code
        ,copy_from_row.orig_system_reference
        ,copy_from_row.CHANGE_APPROVER --added for bug 9108474
        );


   IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
   END IF;

   x_ci_id := lx_ci_id;


       ------- copy impacts
      if (x_return_status = FND_API.g_ret_sts_success) then
           pa_ci_impacts_util.copy_impact(p_validate_only   => 'F',
                                     p_init_msg_list   => 'F',
                                     P_DEST_CI_ID      => x_ci_id,
                                     P_Source_ci_id    => p_ci_id,
                                     P_INCLUDE_FLAG    => 'N',
                                     x_return_status   => x_return_status,
                                     x_msg_count       => x_msg_count,
                                     x_msg_data        => x_msg_data);
      end if;

   IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
   END IF;

   FOR ci_obj_id_to1 IN c_obj_id_to1
   LOOP

     PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
                      	p_user_id => fnd_global.user_id,
                        p_object_type_from => 'PA_CONTROL_ITEMS',
                        p_object_id_from1 => to_char(x_ci_id),
			p_object_id_from2 => NULL,
			p_object_id_from3 => NULL,
			p_object_id_from4 => NULL,
			p_object_id_from5 => NULL,
			p_object_type_to => 'PA_CONTROL_ITEMS',
                        p_object_id_to1 => to_char(ci_obj_id_to1.object_id_to1),
			p_object_id_to2 => NULL,
			p_object_id_to3 => NULL,
			p_object_id_to4 => NULL,
			p_object_id_to5 => NULL,
                        p_relationship_type => l_relationship_type,
                        p_relationship_subtype => NULL,
			p_lag_day => NULL,
			p_imported_lag => NULL,
			p_priority => NULL,
			p_pm_product_code => NULL,
                        x_object_relationship_id => x_relationship_id,
                        x_return_status => x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
   END IF;

END LOOP;


      --Copying document attachments
        pa_ci_doc_attach_pkg.copy_attachments(
          p_init_msg_list => 'F',
          p_validate_only => 'F',
          p_from_ci_id    => p_ci_id,
          p_to_ci_id      => x_ci_id,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data);

   IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
   END IF;

     --Copying related items
        pa_control_items_pvt.copy_related_items(
          p_init_msg_list => 'F',
          p_validate_only => 'F',
          p_from_ci_id    => p_ci_id,
          p_to_ci_id      => x_ci_id,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data);

  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
   END IF;

   FOR ci_actions_from IN c_action_from
   LOOP

       PA_CI_ACTIONS_PKG.INSERT_ROW(
            P_CI_ACTION_ID => l_action_id,
            P_CI_ID => x_CI_ID,
            P_CI_ACTION_NUMBER => ci_actions_from.ci_action_number,
            P_STATUS_CODE => ci_actions_from.STATUS_CODE,
            P_TYPE_CODE => ci_actions_from.TYPE_CODE,
            P_ASSIGNED_TO => ci_actions_from.ASSIGNED_TO,
            P_DATE_REQUIRED => ci_actions_from.DATE_REQUIRED,
            P_SIGN_OFF_REQUIRED_FLAG => ci_actions_from.SIGN_OFF_REQUIRED_FLAG,
            P_DATE_CLOSED => ci_actions_from.DATE_CLOSED,
            P_SIGN_OFF_FLAG	=> ci_actions_from.SIGN_OFF_FLAG,
            P_SOURCE_CI_ACTION_ID => ci_actions_from.SOURCE_CI_ACTION_ID,
            P_LAST_UPDATED_BY => fnd_global.user_id,
            P_CREATED_BY => fnd_global.user_id,
            P_CREATION_DATE => sysdate,
            P_LAST_UPDATE_DATE => sysdate,
            P_LAST_UPDATE_LOGIN => fnd_global.user_id,
            P_RECORD_VERSION_NUMBER => ci_actions_from.RECORD_VERSION_NUMBER);

     IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
     END IF;

   FOR ci_comments_from IN c_comments_from(ci_actions_from.CI_ACTION_ID)
   LOOP

    PA_CI_COMMENTS_PKG.INSERT_ROW (
      P_CI_COMMENT_ID  => ci_comments_from.CI_COMMENT_ID,
      P_CI_ID => x_ci_id,
      P_TYPE_CODE => ci_comments_from.TYPE_CODE,
      P_COMMENT_TEXT => ci_comments_from.COMMENT_TEXT,
      P_LAST_UPDATED_BY => fnd_global.user_id,
      P_CREATED_BY => fnd_global.user_id,
      P_CREATION_DATE => trunc(sysdate),
      P_LAST_UPDATE_DATE => trunc(sysdate),
      P_LAST_UPDATE_LOGIN => fnd_global.user_id,
      P_CI_ACTION_ID => l_action_id);

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
    END IF;

   END LOOP;

   END LOOP;


   FOR ci_comments_from IN c_comments_from1
   LOOP

    PA_CI_COMMENTS_PKG.INSERT_ROW (
      P_CI_COMMENT_ID  => ci_comments_from.CI_COMMENT_ID,
      P_CI_ID => x_ci_id,
      P_TYPE_CODE => ci_comments_from.TYPE_CODE,
      P_COMMENT_TEXT => ci_comments_from.COMMENT_TEXT,
      P_LAST_UPDATED_BY => fnd_global.user_id,
      P_CREATED_BY => fnd_global.user_id,
      P_CREATION_DATE => trunc(sysdate),
      P_LAST_UPDATE_DATE => trunc(sysdate),
      P_LAST_UPDATE_LOGIN => fnd_global.user_id,
      P_CI_ACTION_ID => null);

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
    END IF;

   END LOOP;

   l_old_supp_yn := 'N';
   open c_old_supp;
   fetch c_old_supp into l_old_supp_yn;
   close c_old_supp;

  IF( l_old_supp_yn = 'Y') THEN

   FOR ci_supp_dtls_from IN c_supp_dtls_from
   LOOP

     PA_CI_SUPPLIER_PKG.insert_row (
     	x_rowid                   => x_supp_rowid
     	,x_ci_transaction_id      => x_supp_ci_transaction_id
     	,p_CI_TYPE_ID             => ci_supp_dtls_from.ci_type_id
     	,p_CI_ID           	  => x_ci_id
     	,p_CI_IMPACT_ID           => ci_supp_dtls_from.ci_impact_id
     	,p_VENDOR_ID              => ci_supp_dtls_from.vendor_id
        ,p_PO_HEADER_ID           => ci_supp_dtls_from.po_header_id
        ,p_PO_LINE_ID             => ci_supp_dtls_from.po_line_id
        ,p_ADJUSTED_TRANSACTION_ID => ci_supp_dtls_from.ADJUSTED_CI_TRANSACTION_ID
        ,p_CURRENCY_CODE           => ci_supp_dtls_from.CURRENCY_CODE
        ,p_CHANGE_AMOUNT           => ci_supp_dtls_from.CHANGE_AMOUNT
        ,p_CHANGE_TYPE             => ci_supp_dtls_from.CHANGE_TYPE
        ,p_CHANGE_DESCRIPTION      => ci_supp_dtls_from.CHANGE_DESCRIPTION
        ,p_CREATED_BY              => FND_GLOBAL.login_id
        ,p_CREATION_DATE           => trunc(sysdate)
        ,p_LAST_UPDATED_BY         => FND_GLOBAL.login_id
        ,p_LAST_UPDATE_DATE        => trunc(sysdate)
        ,p_LAST_UPDATE_LOGIN       => FND_GLOBAL.login_id
        ,p_Task_Id                 => ci_supp_dtls_from.Task_Id
	,p_Resource_List_Mem_Id    => ci_supp_dtls_from.Resource_List_Member_Id
	,p_From_Date               => ci_supp_dtls_from.FROM_CHANGE_DATE
	,p_To_Date                 => ci_supp_dtls_from.TO_CHANGE_DATE
	,p_Estimated_Cost          => ci_supp_dtls_from.Estimated_Cost
	,p_Quoted_Cost             => ci_supp_dtls_from.Quoted_Cost
	,p_Negotiated_Cost         => ci_supp_dtls_from.Negotiated_Cost
	,p_Burdened_cost           => ci_supp_dtls_from.Burdened_cost
	,p_revenue_override_rate  => ci_supp_dtls_from.revenue_override_rate
        ,p_audit_history_number    => null--nvl(ci_supp_dtls_from.audit_history_number,1)
        ,p_current_audit_flag      =>  'Y'
        ,p_Original_supp_trans_id     =>  null
        ,p_Source_supp_trans_id       =>  null
	,p_ci_status               => null
        ,x_return_status           => x_return_status
        ,x_error_msg_code          => x_error_msg_code  );

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
    END IF;

   END LOOP;


  END IF;



   update PA_CONTROL_ITEMS
   set Current_Version_flag = 'N'
   where ci_id = p_ci_id;

   update PA_CI_SUPPLIER_DETAILS
   set current_audit_flag = 'N'
   where ci_id = p_ci_id;

 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


EXCEPTION
   WHEN G_EXCEPTION_ERROR THEN
    ROLLBACK TO copy_change_doc;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);
    RAISE;

  WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO copy_change_doc;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);
    RAISE;

  WHEN OTHERS THEN
    --ROLLBACK TO copy_change_doc;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_COPY_CHANGE_DOC_PVT',
                            p_procedure_name => 'COPY_CONTROL_ITEM',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
    RAISE;




END  COPY_CONTROL_ITEM;

procedure copy_change_doc(
        p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
        ,p_commit               IN     VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN     VARCHAR2 := FND_API.g_true
        ,p_ci_id                IN     NUMBER
        ,p_ci_number            IN     VARCHAR2
        ,p_version_comments     IN     VARCHAR2
        ,x_ci_id                OUT    NOCOPY NUMBER
        ,x_version_number       OUT    NOCOPY NUMBER

        ,x_return_status        OUT    NOCOPY VARCHAR2
        ,x_msg_count            OUT    NOCOPY NUMBER
        ,x_msg_data             OUT    NOCOPY VARCHAR2
) IS

   API_ERROR                           EXCEPTION;

   l_ci_id  NUMBER := p_ci_id;

   lx_ci_id  NUMBER := null;
   lx_version_number  NUMBER := null;

   l_version_number pa_control_items.version_number%type := null;
   cursor c_vers_num
        is
          select max(nvl(version_number,0))
          from PA_CONTROL_ITEMS
          where ci_id = p_ci_id;

   l_sts_yn varchar2(1) := 'N';
   cursor c_ci_approved
        is
        select 'Y'
        from pa_project_statuses
        where status_type='CONTROL_ITEM'
        and project_system_status_code = 'CI_APPROVED'
        and project_status_code in (select distinct(status_code)
                            from pa_control_items
                            where ci_id =p_ci_id );
BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_COPY_CHANGE_DOC_PVT.COPY_CHANGE_DOC');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed

  --IF p_commit = FND_API.g_true THEN
    SAVEPOINT copy_change_doc;
  --END IF;

  IF p_init_msg_list = FND_API.g_true THEN
    fnd_msg_pub.initialize;
  END IF;

  open c_ci_approved;
  fetch c_ci_approved into l_sts_yn;
  close c_ci_approved;

  if (l_sts_yn = 'Y') then
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_ALL_NO_UPDATE_RECORD');
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  end if;

  open c_vers_num;
  fetch c_vers_num into l_version_number;
  if c_vers_num%NOTFOUND then
       close c_vers_num;
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_CI_NO_VERSION_FOUND');
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  end if;
  close c_vers_num;

  l_version_number := l_version_number+1;
  COPY_CONTROL_ITEM (
         p_ci_id             => p_ci_id   -- copy from this
        ,p_ci_number          => p_ci_number
        ,p_version_number     => l_version_number
        ,p_version_comments   => p_version_comments
        ,x_ci_id              => lx_ci_id
        ,x_version_number     => lx_version_number

        ,x_return_status      => x_return_status
        ,x_msg_count          => x_msg_count
        ,x_msg_data           => x_msg_data
   );
   x_ci_id := lx_ci_id;
   x_version_number := lx_version_number;

  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
   END IF;
 /*
  IF (p_commit = FND_API.g_true and x_return_status = 'S') THEN
    commit;
  END IF;
*/
 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;



EXCEPTION
  WHEN G_EXCEPTION_ERROR THEN
    ROLLBACK TO copy_change_doc;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);


  WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO copy_change_doc;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);


  WHEN OTHERS THEN
    --IF p_commit = FND_API.g_true THEN
      ROLLBACK TO copy_change_doc;
    --END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_COPY_CHANGE_DOC_PVT',
                            p_procedure_name => 'copy_change_doc',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

END  copy_change_doc;

procedure copy_change_doc(
        p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
        ,p_commit               IN     VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN     VARCHAR2 := FND_API.g_true

        ,p_ci_id                IN     NUMBER
        ,p_src_ci_id                IN     NUMBER
        ,x_ci_id                OUT    NOCOPY NUMBER
        ,x_version_number       OUT    NOCOPY NUMBER

        ,x_return_status        OUT    NOCOPY VARCHAR2
        ,x_msg_count            OUT    NOCOPY NUMBER
        ,x_msg_data             OUT    NOCOPY VARCHAR2
) IS

   API_ERROR                           EXCEPTION;

   l_ci_id  NUMBER := p_ci_id;

   l_ci_number pa_control_items.ci_number%type := null;
   l_version_comments pa_control_items.version_comments%type := null;

   l_old_supp_yn          VARCHAR2(1) := 'N';

   lx_ci_id  NUMBER := null;
   lx_version_number  NUMBER := null;

   CURSOR c_from_item
	is
	   SELECT ci_number,version_comments
           FROM pa_control_items
	   WHERE ci_id = p_ci_id;

   l_src_ci_id  NUMBER := null;
   CURSOR c_src_item
	is
	   SELECT ci_id
           FROM pa_control_items
	   WHERE original_ci_id = p_ci_id;

   l_version_number pa_control_items.version_number%type := null;
   cursor c_vers_num
        is
          select max(nvl(version_number,0))
          from PA_CONTROL_ITEMS
          where ci_id = p_src_ci_id;

   cursor c_old_supp
        is
          select 'Y'
          from pa_ci_impact_type_usage Usg,
               pa_control_items ci
          where usg.ci_type_id = ci.ci_type_id
          and ci.ci_id = p_ci_id
          and usg.impact_type_code = 'SUPPLIER';

   l_sts_yn varchar2(1) := 'N';
   cursor c_ci_approved
        is
        select 'Y'
        from pa_project_statuses
        where status_type='CONTROL_ITEM'
        and project_system_status_code = 'CI_APPROVED'
        and project_status_code in (select distinct(status_code)
                            from pa_control_items
                            where ci_id =p_src_ci_id );

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_COPY_CHANGE_DOC_PVT.COPY_CHANGE_DOC');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed

--  IF p_commit = FND_API.g_true THEN
    SAVEPOINT copy_change_doc;
--  END IF;

  IF p_init_msg_list = FND_API.g_true THEN
    fnd_msg_pub.initialize;
  END IF;

  -- throw error for approved change docs

  IF( p_src_ci_id is null) THEN
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_SRC_CI_ID_IS_NULL');
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  open c_ci_approved;
  fetch c_ci_approved into l_sts_yn;
  close c_ci_approved;

  if (l_sts_yn = 'Y') then
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_ALL_NO_UPDATE_RECORD');
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_ERROR;
  end if;

  open c_vers_num;
  fetch c_vers_num into l_version_number;
  if c_vers_num%NOTFOUND then
       close c_vers_num;
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_CI_NO_VERSION_FOUND');
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  end if;
  close c_vers_num;

-- set the current version to no
   update PA_CONTROL_ITEMS
   set Current_Version_flag = 'N'
   where ci_id = p_src_ci_id;

   update PA_CI_SUPPLIER_DETAILS
   set current_audit_flag = 'N'
   where ci_id = p_src_ci_id;

  PA_CHNGE_DOC_POLICY_PVT.SET_CHNGE_DOC_VERS; -- sets policy to n

 -- set the selected version for copy current flag to yes
   update PA_CONTROL_ITEMS
   set Current_Version_flag = 'Y'
   where ci_id = p_ci_id;

  PA_CHNGE_DOC_POLICY_PVT.RESET_CHNGE_DOC_VERS; -- sets policy to y

 -- set the selected version for copy current flag to yes
  PA_CHNGE_DOC_POLICY_PVT.SET_SUPP_AUDT; -- sets policy to n

   update PA_CI_SUPPLIER_DETAILS sdp
   set current_audit_flag = 'Y'
   where sdp.ci_id = p_ci_id
   and sdp.audit_history_number = (select max(sdc.audit_history_number)
                                   from PA_CI_SUPPLIER_DETAILS sdc
                                   where sdc.original_supp_trans_id =  sdp.original_supp_trans_id
                                   group by sdc.original_supp_trans_id);

   PA_CHNGE_DOC_POLICY_PVT.RESET_SUPP_AUDT; -- sets policy to y

  open c_from_item;
  fetch c_from_item into l_ci_number,l_version_comments;
  close c_from_item;

  l_version_number := l_version_number+1;
  COPY_CONTROL_ITEM (
         p_ci_id              => p_ci_id   -- copy from this
        ,p_ci_number          => l_ci_number
        ,p_version_number     => l_version_number
        ,p_version_comments   => l_version_comments

        ,x_ci_id              => lx_ci_id
        ,x_version_number     => lx_version_number

        ,x_return_status      => x_return_status
        ,x_msg_count          => x_msg_count
        ,x_msg_data           => x_msg_data
   );
   x_ci_id := lx_ci_id;
   x_version_number := lx_version_number;

  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
   END IF;

  PA_CHNGE_DOC_POLICY_PVT.SET_CHNGE_DOC_VERS; -- sets policy to n
  -- sets the current ci id whic got versioned above source ci id
   update PA_CONTROL_ITEMS
   set source_ci_id = x_ci_id
   where ci_id = p_src_ci_id;

  PA_CHNGE_DOC_POLICY_PVT.RESET_CHNGE_DOC_VERS; -- sets policy to y
/*
  IF (p_commit = FND_API.g_true and x_return_status = 'S') THEN
    commit;
  END IF;
*/
 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

EXCEPTION
  WHEN G_EXCEPTION_ERROR THEN
    ROLLBACK TO copy_change_doc;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);


  WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO copy_change_doc;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);


  WHEN OTHERS THEN
    --IF p_commit = FND_API.g_true THEN
      ROLLBACK TO copy_change_doc;
    --END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_COPY_CHANGE_DOC_PVT',
                            p_procedure_name => 'copy_change_doc',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

END  copy_change_doc;
procedure update_comments(
        p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
        ,p_commit               IN     VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN     VARCHAR2 := FND_API.g_true

        ,p_ci_id                IN     NUMBER
        ,p_version_comments     IN    VARCHAR2

        ,x_return_status        OUT    NOCOPY VARCHAR2
        ,x_msg_count            OUT    NOCOPY NUMBER
        ,x_msg_data             OUT    NOCOPY VARCHAR2
) IS

   API_ERROR                           EXCEPTION;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_COPY_CHANGE_DOC_PVT.update_comments');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed

  --IF p_commit = FND_API.g_true THEN
    SAVEPOINT update_comments;
  --END IF;

  IF p_init_msg_list = FND_API.g_true THEN
    fnd_msg_pub.initialize;
  END IF;

  IF( p_ci_id is null) THEN
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_CI_ID_IS_NULL');
       x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  PA_CHNGE_DOC_POLICY_PVT.SET_CHNGE_DOC_VERS; -- sets to N end;

   update PA_CONTROL_ITEMS
   set version_comments = p_version_comments
   where ci_id = p_ci_id;

  PA_CHNGE_DOC_POLICY_PVT.RESET_CHNGE_DOC_VERS;  -- sets to Y

IF (p_commit = FND_API.g_true and x_return_status = 'S') THEN
    commit;
  END IF;

 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

EXCEPTION
  WHEN G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_comments;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);


  WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_comments;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);


  WHEN OTHERS THEN
    --IF p_commit = FND_API.g_true THEN
      ROLLBACK TO update_comments;
    --END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_COPY_CHANGE_DOC_PVT',
                            p_procedure_name => 'update_comments',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

END  update_comments;


END  PA_COPY_CHANGE_DOC_PVT;

/
