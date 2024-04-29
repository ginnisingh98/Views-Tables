--------------------------------------------------------
--  DDL for Package Body WIP_OP_LINK_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_OP_LINK_VALIDATIONS" AS
/* $Header: wipolvdb.pls 120.0 2005/05/25 08:11:31 appldev noship $ */

TYPE link_type IS RECORD (
        id      NUMBER,
        from_id NUMBER,
        to_id   NUMBER,
        status  NUMBER);

TYPE link_table IS TABLE OF link_type
    INDEX BY BINARY_INTEGER;

links   link_table;
next_link_id    number  := 0;

procedure insert_error(P_INTERFACE_ID NUMBER,  P_ERROR VARCHAR2, P_ERROR_TYPE NUMBER) IS
BEGIN
/** Bug 2728127 -- removing GROUP_ID from insert as table 'wip_interface_errors'
               does not have the column--this causes package to be INVALID **/
          insert into wip_interface_errors (INTERFACE_ID, ERROR_TYPE, ERROR)
                   values (P_INTERFACE_ID, P_ERROR_TYPE, P_ERROR);
/** Not removing the 'commit' statement here as i don't know the impact of
    removing right now
    Also, not introducing 'PRAGMA AUTONOMOUS...' as it is not used anywhere
    as per ID tool serach and filesystem grep -- not sure why this is present
    here
**/
          commit;
END insert_error;

procedure Exist_Op_Link(p_group_id in number, p_wip_entity_id in number, p_organization_id in number,
                         p_subst_type in number, x_err_code out nocopy varchar2,
                         x_err_msg out nocopy varchar2, x_return_status out nocopy varchar2);

function IS_Error(p_group_id            number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number) return number IS

x_count number := 0;

BEGIN

        SELECT count(*)
          INTO x_count
          FROM WIP_JOB_DTLS_INTERFACE
         WHERE group_id         = p_group_id
           AND process_status   = WIP_CONSTANTS.ERROR
           AND wip_entity_id    = p_wip_entity_id
           AND organization_id  = p_organization_id
           AND load_type        = WIP_JOB_DETAILS.WIP_OP_LINK
           AND substitution_type= p_substitution_type;


        IF x_count <> 0 THEN
           return 1;
        ELSE return 0;
        END IF;

END IS_Error;


procedure Create_Link_Table(p_wip_entity_id in number, p_organization_id in number,
                 x_err_code out nocopy varchar2, x_err_msg out nocopy varchar2,
                 x_return_status out nocopy varchar2) is
     CURSOR c_link_rows IS
          SELECT prior_operation, next_operation
          FROM wip_operation_networks
          WHERE wip_entity_id = p_wip_entity_id
          AND organization_id = p_organization_id;

     l_id number;
     next_link_id    number  := 1;

Begin
      FOR cur_row in c_link_rows LOOP

      l_id := next_link_id;
      next_link_id := next_link_id + 1;
      links(l_id).id := l_id;
      links(l_id).from_id := to_number(cur_row.prior_operation);
      links(l_id).to_id := to_number(cur_row.next_operation);
      END LOOP;

/*
           x_err_msg := 'ERROR:  Create Link TAble.';
           x_err_code := l_id;
           x_return_status := FND_API.G_RET_STS_ERROR;
*/
END Create_Link_Table;

/************************************************
 *  Check whether there are links leading       *
 *  from_id to to_id.                           *
 *  This is used by function Is_Op_Completed  *
 *  to detect link loop.                        *
 ************************************************/
FUNCTION reachable(from_id number, to_id number) RETURN BOOLEAN IS
  l_index number;

BEGIN

  if from_id = to_id then
    return true;
  end if;
  if links.count > 0 then
    l_index := links.first;
    loop
      if links(l_index).from_id = from_id then
        if reachable(links(l_index).to_id, to_id) then
          return true;
        end if;
      end if;
      exit when l_index = links.last;
      l_index := links.next(l_index);
    end loop;
  end if;
  return false;
END reachable;

procedure Loop_Exists(p_group_id in number, p_wip_entity_id in number, p_organization_id in number,
                 p_subst_type in number, x_err_code out nocopy varchar2, x_err_msg out nocopy varchar2,
                 x_return_status out nocopy varchar2) is
    CURSOR c_link_rows IS
          select interface_id, operation_seq_num, next_network_op_seq_num
          FROM WIP_JOB_DTLS_INTERFACE wjdi
          WHERE  wjdi.group_id = p_group_id
          AND process_phase = WIP_CONSTANTS.ML_VALIDATION
          AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
          AND wip_entity_id = p_wip_entity_id
          AND organization_id = p_organization_id
          AND load_type = WIP_JOB_DETAILS.WIP_OP_LINK
          AND substitution_type = p_subst_type;
/*          AND exists (select 1
            FROM WIP_OPERATION_NETWORKS
            WHERE wip_entity_id = wjdi.wip_entity_id
            AND  organization_id = wjdi.organization_id
            AND  prior_operation = wjdi.operation_seq_num
            AND  next_operation = wjdi.next_network_op_seq_num);
*/
     l_error_exists boolean := false;
     l_interface_id number;

Begin
      FOR cur_row in c_link_rows LOOP

      if (reachable(cur_row.operation_seq_num, cur_row.next_network_op_seq_num)) then
           l_error_exists := true;
           fnd_message.set_name('WIP', 'WIP_INV_OP_LINK');
           fnd_message.set_token('INTERFACE', to_char(cur_row.interface_id));
           wip_interface_err_Utils.add_error(p_interface_id => cur_row.interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
      end if;

      END LOOP;

      if(l_error_exists) then
         update wip_job_dtls_interface wjdi
           set process_status = wip_constants.error
         where wjdi.group_id = p_group_id
           and process_phase = wip_constants.ml_validation
           and process_status in (wip_constants.running,
                                  wip_constants.pending,
                                  wip_constants.warning)
           and wip_entity_id = p_wip_entity_id
           and organization_id = p_organization_id
           and load_type = wip_job_details.wip_op_link
           and substitution_type = p_subst_type;
      end if;

End Loop_Exists;

Procedure Validate_Op_Seq_Num(p_group_id  in number,
                  p_wip_entity_id         in number,
                  p_organization_id       in number,
                  p_subst_type            in number,
                  p_operation_seq_num     in number) IS

     CURSOR c_invalid_op_seq_num IS
          select interface_id
          FROM WIP_JOB_DTLS_INTERFACE wjdi
          WHERE  wjdi.group_id = p_group_id
          AND process_phase = WIP_CONSTANTS.ML_VALIDATION
          AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
          AND wip_entity_id = p_wip_entity_id
          AND organization_id = p_organization_id
          AND load_type = WIP_JOB_DETAILS.WIP_OP_LINK
          AND substitution_type = p_subst_type
          AND not exists (select 1
            FROM WIP_OPERATIONS
            WHERE wip_entity_id = p_wip_entity_id
            AND  organization_id = p_organization_id
            AND  operation_seq_num = p_operation_seq_num);

     l_error_exists boolean := false;
     l_op_seq_num number;

BEGIN
    Open  c_invalid_op_seq_num;
    fetch c_invalid_op_seq_num into l_op_seq_num;
    if c_invalid_op_seq_num%FOUND then
           l_error_exists := true;
           fnd_message.set_name('WIP', 'WIP_OP_DOES_NOT_EXIST');
           fnd_message.set_token('INTERFACE', to_char(l_op_seq_num));
           wip_interface_err_Utils.add_error(p_interface_id => l_op_seq_num,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
    end if;
    close c_invalid_op_seq_num;

    if(l_error_exists) then
         update wip_job_dtls_interface wjdi
           set process_status = wip_constants.error
         where wjdi.group_id = p_group_id
           and process_phase = wip_constants.ml_validation
           and process_status in (wip_constants.running,
                                  wip_constants.pending,
                                  wip_constants.warning)
           and wip_entity_id = p_wip_entity_id
           and organization_id = p_organization_id
           and load_type = wip_job_details.wip_op_link
           and substitution_type = p_subst_type;
    end if;

END Validate_Op_Seq_Num;

procedure Exist_Op_Seq_Num(p_group_id in number, p_wip_entity_id in number, p_organization_id in number,
                 p_subst_type in number) IS

   CURSOR op_link_info IS
   SELECT distinct operation_seq_num,
          next_network_op_seq_num,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_OP_LINK
      AND substitution_type = p_subst_type;

      l_operation_seq_num number;
      from_id number;
      to_id number;
     l_error_exists boolean := false;
     l_interface_id number;

BEGIN

  FOR cur_row in op_link_info LOOP
    from_id := cur_row.operation_seq_num;
    to_id := cur_row.next_network_op_seq_num;
    Validate_Op_Seq_Num(p_group_id, p_wip_entity_id, p_organization_id,
                        p_subst_type, cur_row.operation_seq_num);
    Validate_Op_Seq_Num(p_group_id, p_wip_entity_id, p_organization_id,
                        p_subst_type, cur_row.next_network_op_seq_num);
  END LOOP;
end;

procedure Is_Op_Completed(p_group_id in number, p_wip_entity_id in number, p_organization_id in number,
                 p_subst_type in number) IS

   CURSOR op_link_info IS
   SELECT distinct operation_seq_num,
          next_network_op_seq_num,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_OP_LINK
      AND substitution_type = p_subst_type;

      l_completed varchar2(30) := 'N';
      l_prev_op_complete  varchar2(30) := 'N';
      l_next_op_start_date  date := sysdate;
      l_previous_op_completion_date date := sysdate;
      l_operation_seq_num number;
      from_id number;
      to_id number;
     l_error_exists boolean := false;
     l_interface_id number;

BEGIN

  FOR cur_row in op_link_info LOOP
    from_id := cur_row.operation_seq_num;
    to_id := cur_row.next_network_op_seq_num;
    l_operation_seq_num := to_id;

    if (p_wip_entity_id is not null and to_id is not null and from_id is not null) then
    begin
        select operation_completed,first_unit_start_date
        into l_completed, l_next_op_start_date
        from wip_operations
        where wip_entity_id = p_wip_entity_id
          and operation_seq_num = l_operation_seq_num;
      exception
        when others then
          null;
      end;

     l_operation_seq_num := from_id;
     begin
           select operation_completed, last_unit_completion_date
           into l_prev_op_complete, l_previous_op_completion_date
           from wip_operations
           where wip_entity_id = p_wip_entity_id
             and operation_seq_num = l_operation_seq_num;
         exception
           when others then
             null;
      end;

      select interface_id into l_interface_id
          FROM WIP_JOB_DTLS_INTERFACE wjdi
          WHERE  wjdi.group_id = p_group_id
          AND process_phase = WIP_CONSTANTS.ML_VALIDATION
          AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
          AND wip_entity_id = p_wip_entity_id
          AND organization_id = p_organization_id
          AND load_type = WIP_JOB_DETAILS.WIP_OP_LINK
          AND operation_seq_num = from_id
          AND next_network_op_seq_num = to_id
          AND substitution_type = p_subst_type;

      if (nvl(l_completed, 'N') = 'Y' and nvl(l_prev_op_complete,'N') = 'N') then
           l_error_exists := true;
           FND_MESSAGE.SET_NAME('EAM', 'EAM_OP_TO_COMPLETE');
           fnd_message.set_token('INTERFACE', to_char(l_interface_id));
           wip_interface_err_Utils.add_error(p_interface_id => l_interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);

      end if;

      if (nvl(l_prev_op_complete,'N') = 'Y') then
           l_error_exists := true;
           FND_MESSAGE.SET_NAME('EAM', 'EAM_OP_FROM_COMPLETE');
           fnd_message.set_token('INTERFACE', to_char(l_interface_id));
           wip_interface_err_Utils.add_error(p_interface_id => l_interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);

      end if;

      if (l_next_op_start_date < l_previous_op_completion_date ) then
           l_error_exists := true;
           FND_MESSAGE.SET_NAME('EAM', 'EAM_DEP_OP_START_DATE_INVALID');
           fnd_message.set_token('INTERFACE', to_char(l_interface_id));
           wip_interface_err_Utils.add_error(p_interface_id => l_interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
      end if;
    end if;

    if(l_error_exists) then
         update wip_job_dtls_interface wjdi
           set process_status = wip_constants.error
         where wjdi.group_id = p_group_id
           and process_phase = wip_constants.ml_validation
           and process_status in (wip_constants.running,
                                  wip_constants.pending,
                                  wip_constants.warning)
           and wip_entity_id = p_wip_entity_id
           and organization_id = p_organization_id
           and load_type = wip_job_details.wip_op_link
           and substitution_type = p_subst_type;

    end if;
  END Loop;
/*
    wip_interface_err_Utils.load_errors;

 fnd_message.set_name('WIP', 'WIP_OP_LINK_NOT_FOUND');
 fnd_message.set_token('INTERFACE', 4567);
 insert into wip_interface_errors (
      interface_id,
      error_type,
      error,
      last_update_date,
      creation_date
    ) values (
      4567,
      1,
      substr(fnd_message.get,1,500),
      sysdate,
      sysdate
    );
   commit;
*/
END Is_Op_Completed;

procedure Exist_Op_Link(p_group_id in number, p_wip_entity_id in number, p_organization_id in number,
                 p_subst_type in number, x_err_code out nocopy varchar2, x_err_msg out nocopy varchar2,
                 x_return_status out nocopy varchar2) is

     CURSOR c_op_link_rows IS
          select interface_id
          FROM WIP_JOB_DTLS_INTERFACE wjdi
          WHERE  wjdi.group_id = p_group_id
          AND process_phase = WIP_CONSTANTS.ML_VALIDATION
          AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
          AND wip_entity_id = p_wip_entity_id
          AND organization_id = p_organization_id
          AND load_type = WIP_JOB_DETAILS.WIP_OP_LINK
          AND substitution_type = p_subst_type
          AND exists (select 1
            FROM WIP_OPERATION_NETWORKS
            WHERE wip_entity_id = wjdi.wip_entity_id
            AND  organization_id = wjdi.organization_id
            AND  prior_operation = wjdi.operation_seq_num
            AND  next_operation = wjdi.next_network_op_seq_num);

     l_error_exists boolean := false;
     l_interface_id number;

begin

    Open    c_op_link_rows;
    fetch c_op_link_rows into l_interface_id;
    if (p_subst_type = WIP_JOB_DETAILS.WIP_DELETE) then
       if    c_op_link_rows%NOTFOUND then
           l_error_exists := true;
           fnd_message.set_name('WIP', 'WIP_OP_LINK_NOT_FOUND');
           fnd_message.set_token('INTERFACE', to_char(l_interface_id));
           wip_interface_err_Utils.add_error(p_interface_id => l_interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
       end if;
    elsif  (p_subst_type = WIP_JOB_DETAILS.WIP_ADD) then
       if c_op_link_rows%FOUND then
           l_error_exists := true;
           fnd_message.set_name('WIP', 'WIP_OP_LINK_EXISTS');
           fnd_message.set_token('INTERFACE', to_char(l_interface_id));
           wip_interface_err_Utils.add_error(p_interface_id => l_interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
       end if;
    end if;
    close c_op_link_rows;

    if(l_error_exists) then
         update wip_job_dtls_interface wjdi
           set process_status = wip_constants.error
         where wjdi.group_id = p_group_id
           and process_phase = wip_constants.ml_validation
           and process_status in (wip_constants.running,
                                  wip_constants.pending,
                                  wip_constants.warning)
           and wip_entity_id = p_wip_entity_id
           and organization_id = p_organization_id
           and load_type = wip_job_details.wip_op_link
           and substitution_type = p_subst_type;
    end if;

/*         x_return_status := FND_API.G_RET_STS_ERROR;
         x_err_msg := 'ERROR IN WIPOPVDB.ADD_OPERATION: Deleting a non-existing operation link' ;
         x_err_code := -9999;
*/

end;


/* main delete, call the above. If any validation fail, it won't go on
   with the next validations */
Procedure Delete_Op_Link(p_group_id          in number,
                     p_wip_entity_id         in number,
                     p_organization_id       in number,
                     p_substitution_type     in number,
                     x_err_code              out nocopy varchar2,
                     x_err_msg               out nocopy varchar2,
                     x_return_status         out nocopy varchar2) IS

BEGIN

    Exist_Op_Link(p_group_id, p_wip_entity_id, p_organization_id, p_substitution_type,
                             x_err_code , x_err_msg, x_return_status);

    Exception

    when others then
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_err_msg := 'ERROR IN WIPOLVDB.DELETE_OP_LINK: ' || SQLERRM;
      x_err_code := to_char(SQLCODE);

    return;

END Delete_Op_Link;

/* main add, call the above */
Procedure Add_Op_Link(p_group_id               in number,
                  p_wip_entity_id         in number,
                  p_organization_id       in number,
                  p_substitution_type     in number,
                  x_err_code              out nocopy varchar2,
                  x_err_msg               out nocopy varchar2,
                   x_return_status         out nocopy varchar2) IS

   CURSOR op_link_info(p_group_Id           number,
                   p_wip_entity_id      number,
                   p_organization_id    number,
                   p_substitution_type  number) IS
   SELECT distinct operation_seq_num,
          next_network_op_seq_num,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_OP_LINK
      AND substitution_type = p_substitution_type;

BEGIN

    Exist_Op_Link(p_group_id, p_wip_entity_id, p_organization_id, p_substitution_type,
                             x_err_code , x_err_msg, x_return_status);
    IF IS_Error(p_group_id,
            p_wip_entity_id,
            p_organization_id,
            p_substitution_type) = 0 then

       Is_Op_Completed(p_group_id, p_wip_entity_id, p_organization_id, p_substitution_type);
       IF IS_Error(p_group_id,
            p_wip_entity_id,
            p_organization_id,
            p_substitution_type) = 0 then

            Exist_Op_Seq_Num(p_group_id, p_wip_entity_id, p_organization_id,
                                        p_substitution_type);
            IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type) = 0 then

               Create_Link_Table( p_wip_entity_id, p_organization_id,
                               x_err_code , x_err_msg, x_return_status);
               Loop_Exists(p_group_id, p_wip_entity_id, p_organization_id, p_substitution_type,
                            x_err_code , x_err_msg, x_return_status);
               End If;
           End If;
    End If;

    --wip_interface_err_Utils.load_errors;

    Exception

    when others then
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_err_msg := 'ERROR IN WIPOLVDB.ADD_OP_LINK: ' || SQLERRM;
      x_err_code := to_char(SQLCODE);

    return;

END Add_Op_Link;

END WIP_OP_LINK_VALIDATIONS;

/
