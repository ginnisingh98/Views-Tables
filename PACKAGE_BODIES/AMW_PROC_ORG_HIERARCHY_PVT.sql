--------------------------------------------------------
--  DDL for Package Body AMW_PROC_ORG_HIERARCHY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_PROC_ORG_HIERARCHY_PVT" as
/* $Header: amwvpohb.pls 120.0 2005/05/31 20:34:58 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_Proc_Org_PVT
-- Purpose
--
-- History
--        mpande updated 11/13/2003 bug#3191406
-- NOTE
--
-- End of Comments
-- ===============================================================

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMW_PROC_ORG_HIERARCHY_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amwvpohb.pls';

G_USER_ID NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_RISK_COUNT number := 0;
G_control_COUNT number := 0;

  --------------------- BEGIN: Declaring internal Procedures ----------------------

  --------------------- END: Declaring internal Procedures ----------------------
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Process_Process_Hierarchy
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_process_id              IN   NUMBER     Optional  Default = null
--       p_organization_id         IN   NUMBER     Optional  Default = null
--       p_mode                    IN   VARCHAR2   Required  Default = 'ASSOCIATE'
--       p_apo_type                IN   apo_type   Optional  Default = null
--       p_commit                  IN   VARCHAR2   Required  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:
--
--   End of Comments
--   ==============================================================================
--
procedure process_process_hierarchy(
  p_process_id in number := null,
  p_organization_id in number := null,
  p_mode in varchar2 := 'ASSOCIATE',
  p_level in number := 0,
  p_apo_type in apo_type := g_miss_apo_type,
  p_commit in varchar2 := FND_API.G_FALSE,
  p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
  x_return_status out nocopy varchar2,
  x_msg_count out nocopy number,
  x_msg_data out nocopy varchar2
)

is
  L_API_NAME CONSTANT VARCHAR2(30) := 'Process_Process_Hierarchy';
  x_process_organization_id number := 0;
  ----l_top_process_id number := p_process_id;
  l_top_process_id number;

  l_return_status varchar2(30) := 'false';
  l_msg_count number;
  l_msg_data varchar2(3000) := 'empty';

  /**
  cursor c1 is
    select child_process_id,parent_process_id,parent_process_name,process_name from amw_process_hierarchy_v
    start with child_process_id=p_process_id
   connect by prior child_process_id=parent_process_id;
  **/

  cursor c1 (l_cpid number) is
    select parent_process_id,child_process_id,parent_process_name,process_name
   from amw_process_hierarchy_v
    where parent_process_id=l_cpid;

  cursor risk_ctrl is
    select nvl(risk_count,0) as risk_count,
          nvl(control_count,0) as control_count
   from amw_process
   where process_id=p_process_id;
   ---and organization_id=p_organization_id;

  l_risk_ctrl risk_ctrl%rowtype;

  l_process_id c1%rowtype;
  l_apo_type apo_type := p_apo_type;
  l_level number := 0;
  l_ppid number := 0;
  l_mode varchar2(30) := p_mode;

begin
  savepoint process_process_hierarchy_pub;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
     FND_MSG_PUB.initialize;
  END IF;

  /* Temporarily commenting out the validata session code ..... */
  -- =========================================================================
  -- Validate Environment
  -- =========================================================================
  IF FND_GLOBAL.User_Id IS NULL
  THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF(p_validation_level >= FND_API.G_VALID_LEVEL_FULL)
  THEN
    -- Debug message
    AMW_UTILITY_PVT.debug_message('Private API: Validate_Process');

   -- Invoke validation procedures
   l_apo_type.process_id := p_process_id;
   l_apo_type.organization_id := p_organization_id;
   l_level := p_level;

    validate_apo_type(
      p_api_version_number => 1.0,
      p_init_msg_list => FND_API.G_FALSE,
      p_validation_level => p_validation_level,
      p_apo_type => l_apo_type,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data  => x_msg_data);
  END IF;

  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- =========================================================================
  -- End Validate Environment
  -- =========================================================================
  -- End commenting the session validation code ....


  if p_process_id is null or p_organization_id is null
  then
    -----------DBMS_OUTPUT.PUT_LINE ('ERROR -- exiting');
   RAISE FND_API.G_EXC_ERROR;
  end if;

--  open c1;
--    loop
--      fetch c1 into l_process_id;
--     EXIT WHEN c1%NOTFOUND;

      if(p_level=0)then
       l_top_process_id := p_process_id;

      ---select parent_process_id into l_ppid from amw_process_hierarchy_v
      ---where child_process_id=p_process_id;

      l_ppid := get_parent_process_id(p_process_id,p_organization_id);
      ----dbms_output.put_line('l_ppid: '||l_ppid);
   ---end if;

      associate_process_org(
          p_apo_type => l_apo_type,
          p_process_id => p_process_id,
          p_top_process_id => l_top_process_id,
          p_organization_id => p_organization_id,
          p_parent_process_id => l_ppid,
          p_mode => p_mode,
          p_commit => p_commit,
          p_validation_level => p_validation_level,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data
        );
     end if;

     for l_process_id in c1(p_process_id) loop
     exit when c1%notfound;
       x_return_status := FND_API.G_RET_STS_SUCCESS;

      ---dbms_output.put_line('child_process_id: '||l_process_id.child_process_id);

      associate_process_org(
          p_apo_type => l_apo_type,
          p_process_id => l_process_id.child_process_id,
          p_top_process_id => l_top_process_id,
          p_organization_id => p_organization_id,
          p_parent_process_id => l_process_id.parent_process_id,
          p_mode => l_mode,
          p_commit => p_commit,
          p_validation_level => p_validation_level,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data
        );

      l_level := l_level+1;
      process_process_hierarchy(p_process_id =>l_process_id.child_process_id,
                         p_organization_id => p_organization_id,
                         p_mode => l_mode,
                         p_level => l_level,
                         p_commit => p_commit,
                         x_return_status => x_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data);
     end loop;

     ---dbms_output.put_line('Done with the recursion loop');
    /*
     open risk_ctrl;
        loop
         fetch risk_ctrl into l_risk_ctrl;
         exit when risk_ctrl%notfound;
      end loop;
     close risk_ctrl;
     */


     if(p_level=0)then
       process_hierarchy_count(
          p_process_id                =>p_process_id,
          p_organization_id         =>p_organization_id,
          p_risk_count            =>l_risk_ctrl.risk_count,
          p_control_count            =>l_risk_ctrl.control_count,
          p_mode                     =>p_mode,
          p_commit                    =>p_commit,
          x_return_status             =>l_return_status,
          x_msg_count                 =>l_msg_count,
          x_msg_data                  =>l_msg_data
       );
     end if;

      /****
       associate_process_org(
          p_apo_type => l_apo_type,
          p_process_id => l_process_id.child_process_id,
        p_top_process_id => l_top_process_id,
          p_organization_id => p_organization_id,
        p_parent_process_id => l_process_id.parent_process_id,
        p_mode => p_mode,
          p_commit => p_commit,
          p_validation_level => p_validation_level,
        p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data
        );
      --------dbms_output.put_line('Process_Process_Hierarchy x_return_status: '||x_return_status);
      ---------dbms_output.put_line('FND_API.G_RET_STS_SUCCESS: '||FND_API.G_RET_STS_SUCCESS);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      ****/

--  end loop;
--  close c1;

  --Debug Message
  AMW_UTILITY_PVT.debug_message('Private API: ' || L_API_NAME || 'end');

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
  );

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO process_process_hierarchy_pub;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO process_process_hierarchy_pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK TO process_process_hierarchy_pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);
end process_process_hierarchy;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Associate_Process_Org
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_apo_type                IN   apo_type   Optional  Default = null
--       p_process_id              IN   NUMBER     Optional  Default = null
--       p_top_process_id          IN   NUMBER     Optional  Default = null
--       p_organization_id         IN   NUMBER     Optional  Default = null
--       p_parent_process_id       IN   NUMBER     Optional  Default = null
--       p_mode                    IN   VARCHAR2   Required  Default = 'ASSOCIATE'
--       p_commit                  IN   VARCHAR2   Required  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:
--
--   End of Comments
--   ==============================================================================
--

procedure associate_process_org(
  p_apo_type in apo_type := g_miss_apo_type,
  p_process_id in number := null,
  p_top_process_id in number := null,
  p_organization_id in number := null,
  p_parent_process_id in number := null,
  p_rcm_assoc in varchar2 := 'N',
  p_batch_id in number := null,
  p_rcm_org_intf_id in number := null,
  p_risk_id in number := null,
  p_control_id in number := null,
  p_mode in varchar2 := 'ASSOCIATE',

  p_commit in varchar2 := FND_API.G_FALSE,
  p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,

  x_return_status out nocopy varchar2,
  x_msg_count out nocopy number,
  x_msg_data out nocopy varchar2
)

is
  L_API_NAME CONSTANT VARCHAR2(30) := 'Associate_Process_Org';
  x_process_organization_id number := 0;
  l_apo_type apo_type := p_apo_type;

  cursor c1 is
    select significant_process_flag,standard_process_flag,approval_status,
               certification_status,process_category,process_owner_id,process_id,created_from,
             request_id,program_application_id,program_id,program_update_date,
             attribute_category,attribute1,attribute2,attribute3,attribute4,
             attribute5,attribute6,attribute7,attribute8,attribute9,attribute10,
             attribute11,attribute12,attribute13,attribute14,attribute15,
             security_group_id,object_version_number,
             nvl(control_count,0) as control_count,
             nvl(risk_count,0) as risk_count,nvl(org_count,0) as org_count,
	     finance_owner_id,application_owner_id
   from amw_process where process_id=p_process_id;

  l_amwp_rowtype c1%rowtype;
  l_amwp amw_process_organization%rowtype;
  l_count number := 0;
  l_do_insert varchar2(30) := 'INSERT';
  l_org_count number := 0;
  l_parent_process_end_date date := null;

  cursor cc1 is
  select count(*) row_count from amw_process_organization
    where process_id=p_process_id and organization_id=p_organization_id;

  cc1_row cc1%rowtype;

  cursor cc2 is
  select count(*) row_count from amw_process_organization
   where process_id=p_parent_process_id and organization_id=p_organization_id;

  cc2_row cc2%rowtype;

  cursor cc3 is
  select end_date from amw_process_organization
   where process_id=p_parent_process_id and organization_id=p_organization_id;

  cc3_row cc3%rowtype;

  cursor cc4 is
  select count(*) row_count from amw_process_organization
    where process_id=p_parent_process_id and organization_id=p_organization_id;

  cc4_row cc4%rowtype;

  cursor cc5 is
  select end_date from amw_process_organization
   where process_id=p_parent_process_id and organization_id=p_organization_id;

  cc5_row cc5%rowtype;

begin
  savepoint associate_process_org_pvt;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  ----DBMS_OUTPUT.PUT_LINE ( 'associate_process_org:' );
  ----DBMS_OUTPUT.PUT_LINE ( 'top process id being passed to INSERT_IN_AMWPO:'|| p_top_process_id);

  open c1;
    loop
     fetch c1 into l_amwp_rowtype;
     exit when c1%notfound;

     if(l_amwp_rowtype.org_count is null) then
       l_org_count := 0;
     else
       l_org_count := l_amwp_rowtype.org_count;
      end if;

     l_apo_type.control_count := l_amwp_rowtype.control_count;
     l_apo_type.risk_count := l_amwp_rowtype.risk_count;
     l_apo_type.TOP_PROCESS_ID := p_top_process_id;
     l_apo_type.process_organization_id := null;
     l_apo_type.last_update_date := sysdate;
     l_apo_type.last_updated_by := G_USER_ID;
     l_apo_type.creation_date := sysdate;
     l_apo_type.created_by := G_USER_ID;
     l_apo_type.LAST_UPDATE_LOGIN := G_LOGIN_ID;
     l_apo_type.PROCESS_ID := p_PROCESS_ID;
     l_apo_type.STANDARD_PROCESS_FLAG := l_amwp_rowtype.STANDARD_PROCESS_FLAG;
     l_apo_type.RISK_CATEGORY := null;
     l_apo_type.APPROVAL_STATUS := l_amwp_rowtype.APPROVAL_STATUS;
     l_apo_type.CERTIFICATION_STATUS := l_amwp_rowtype.CERTIFICATION_STATUS;
     l_apo_type.LAST_AUDIT_STATUS := null;
     l_apo_type.ORGANIZATION_ID := p_ORGANIZATION_ID;
     l_apo_type.LAST_CERTIFICATION_DATE := null;
     l_apo_type.LAST_AUDIT_DATE := null;
     l_apo_type.NEXT_AUDIT_DATE := null;
     l_apo_type.application_owner_id := l_amwp_rowtype.APPLICATION_OWNER_ID;
     l_apo_type.process_owner_id := l_amwp_rowtype.process_owner_id;
     l_apo_type.PROCESS_CATEGORY_CODE := l_amwp_rowtype.PROCESS_CATEGORY;
     l_apo_type.SIGNIFICANT_PROCESS_FLAG := l_amwp_rowtype.SIGNIFICANT_PROCESS_FLAG;
     l_apo_type.finance_owner_id := l_amwp_rowtype.FINANCE_OWNER_ID;
     l_apo_type.CREATED_FROM := l_amwp_rowtype.CREATED_FROM;
     l_apo_type.REQUEST_ID := l_amwp_rowtype.REQUEST_ID;
     l_apo_type.PROGRAM_APPLICATION_ID := l_amwp_rowtype.PROGRAM_APPLICATION_ID;
     l_apo_type.PROGRAM_ID := l_amwp_rowtype.PROGRAM_ID;
     l_apo_type.PROGRAM_UPDATE_DATE := l_amwp_rowtype.PROGRAM_UPDATE_DATE;
     l_apo_type.ATTRIBUTE_CATEGORY := l_amwp_rowtype.ATTRIBUTE_CATEGORY;
     l_apo_type.attribute1 := l_amwp_rowtype.attribute1;
     l_apo_type.attribute2 := l_amwp_rowtype.attribute2;
     l_apo_type.attribute3 := l_amwp_rowtype.attribute3;
     l_apo_type.attribute4 := l_amwp_rowtype.attribute4;
     l_apo_type.attribute5 := l_amwp_rowtype.attribute5;
     l_apo_type.attribute6 := l_amwp_rowtype.attribute6;
     l_apo_type.attribute7 := l_amwp_rowtype.attribute7;
     l_apo_type.attribute8 := l_amwp_rowtype.attribute8;
     l_apo_type.attribute9 := l_amwp_rowtype.attribute9;
     l_apo_type.attribute10 := l_amwp_rowtype.attribute10;
     l_apo_type.attribute11 := l_amwp_rowtype.attribute11;
     l_apo_type.attribute12 := l_amwp_rowtype.attribute12;
     l_apo_type.attribute13 := l_amwp_rowtype.attribute13;
     l_apo_type.attribute14 := l_amwp_rowtype.attribute14;
     l_apo_type.attribute15 := l_amwp_rowtype.attribute15;
     l_apo_type.security_group_id := l_amwp_rowtype.security_group_id;
     l_apo_type.OBJECT_VERSION_NUMBER := 1;
     l_apo_type.END_DATE := null; ---amwp_rowtype.END_DATE;

     ---insert into amw_process_organization tbl this process for this organization
     if(p_mode = 'ASSOCIATE') then
       --check to see if this process id exists in amw_process_organization


      select count(*) into l_count from amw_process_organization
      where process_id=p_process_id and organization_id=p_organization_id;
      ---DBMS_OUTPUT.PUT_LINE ( 'associate_process_heirarchy: top_process_id '|| p_top_process_id );
      ---DBMS_OUTPUT.PUT_LINE ( 'l_count for checking if this child process_id '||p_process_id||' exists: '|| l_count);

        -------------------dbms_output.put_line('cc1 l_count: '||l_count);
      if l_count > 0 then
        --this means that this record exists in amw_process_organization table
        --so this row needs to be updated
        l_do_insert := 'UPDATE';
        l_apo_type.TOP_PROCESS_ID := p_process_id;

        --so now we need to check if there is a parent process associated to this node

        select count(*) into l_count from amw_process_organization
        where process_id=p_parent_process_id and organization_id=p_organization_id;

        -----------------dbms_output.put_line('cc2 l_count: '||l_count);
        --if it does then, see if the parent process is associated or disassociated
        if l_count > 0 then

         select end_date into l_parent_process_end_date from amw_process_organization
         where process_id=p_parent_process_id and organization_id=p_organization_id;

         ------------------dbms_output.put_line('cc3 l_parent_process_end_date: '||l_parent_process_end_date);
         if l_parent_process_end_date is not null then
           --so this process row exists in amw_process_organization, so no new row insertion
           --this node has a parent process in amw_process_organization which is disassociated
           --so this parent process needs to be updated with top_process_id set to this p_id
           l_apo_type.TOP_PROCESS_ID := p_process_id;
           ----l_apo_type.object_version_number := l_apo_type.object_version_number+1;
         else
           l_apo_type.TOP_PROCESS_ID := null;
         end if;
        end if;
      else
        --this means that this record does not exist, but we need to check
        --if the parent_process_id for this process exists in amw_process_organization,
        l_count := 0;


        select count(*) into l_count from amw_process_organization
        where process_id=p_parent_process_id and organization_id=p_organization_id;

        ---------------dbms_output.put_line('cc4 l_count: '||l_count);
        --if it does then

        if l_count > 0 then
          l_do_insert := 'INSERT';


         select end_date into l_parent_process_end_date from amw_process_organization
         where process_id=p_parent_process_id and organization_id=p_organization_id;
         ---------------------dbms_output.put_line('cc5 l_parent_process_end_date: '||l_parent_process_end_date);
          if l_parent_process_end_date is null then
           --  if parent_process' end_date is null (associated parent process,
            --                       insert this record with top_process_id,end_date=null
           l_apo_type.end_date := null;
           l_apo_type.top_process_id := null;
         else
           --  if parent_process' end_date is not null (disassociated parent process,
            --                       insert this record with top_process_id=current process_id
            --                       end_date = null
           l_apo_type.end_date := null;
           l_apo_type.top_process_id := p_process_id;
         end if; -- end of l_parent_process_id check
        end if; --end of l_count for existence of row check

      end if; -- end of p_mode = 'ASSOCIATE'
      elsif p_mode = 'DISASSOCIATE' then
       -----------------DBMS_OUTPUT.PUT_LINE ( 'P_MODE: '|| p_mode||', top_process_id: '||p_top_process_id|| ', process_id: '||p_process_id);
       if p_top_process_id = p_process_id then
         --this is the top most process in the node hierarchy which we want to delete
        l_do_insert := 'DELETE';
        l_apo_type.top_process_id := p_process_id;
        --------------dbms_output.put_line('disassoc mode: top p_process_id: '||p_process_id);
      else
        l_do_insert := 'DELETE';
        l_apo_type.top_process_id := null;
        ----------------dbms_output.put_line('disassoc mode: p_process_id: '||p_process_id);
      end if;
     end if;

     ------------------DBMS_OUTPUT.PUT_LINE ( 'p_mode: '|| p_mode||', l_do_insert: '||l_do_insert);

     process_amw_process_org(
        p_apo_type => l_apo_type,
        p_do_insert => l_do_insert,
        p_org_count => l_org_count,
        p_rcm_assoc => p_rcm_assoc,
        p_batch_id => p_batch_id,
		p_rcm_org_intf_id => p_rcm_org_intf_id,
        p_risk_id => p_risk_id,
        p_control_id => p_control_id,
		p_commit => p_commit,
        p_validation_level => p_validation_level,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
      );

     ---------------------------dbms_output.put_line('Associate_Process_Org x_return_status: '||x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

     AMW_UTILITY_PVT.debug_message('Private API: ' || L_API_NAME || 'end');

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get(
       p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
     );
    end loop;
  close c1;

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO associate_process_org_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO associate_process_org_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK TO associate_process_org_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);

end associate_process_org;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Process_Amw_Process_Org
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_apo_type                IN   apo_type   Optional  Default = null
--       p_do_insert               IN   VARCHAR2   Optional  Default = 'INSERT'
--       p_org_count               IN   NUMBER     Optional  Default = 0
--       p_commit                  IN   VARCHAR2   Required  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:
--
--   End of Comments
--   ==============================================================================
--

procedure process_amw_process_org(
   p_apo_type in apo_type := g_miss_apo_type,
   p_do_insert in varchar2 := 'INSERT',
   p_org_count in number := 0,
   p_rcm_assoc in varchar2 := 'N',
   p_batch_id in number := null,
   p_rcm_org_intf_id in number := null,
   p_risk_id in number := null,
   p_control_id in number := null,
   p_commit in varchar2 := FND_API.G_FALSE,
   p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
   x_return_status out nocopy varchar2,
   x_msg_count out nocopy number,
   x_msg_data out nocopy varchar2
)
is
  L_API_NAME CONSTANT VARCHAR2(30) := 'Create_Process_Org';
  L_API_VERSION_NUMBER CONSTANT NUMBER := 1.0;
  l_process_id number := 0;
  l_organization_id number := 0;
  l_process_organization_id number;
  l_org_count number := 0;
  l_assoc_mode varchar2(30) := 'ASSOCIATE';
  l_obj_num number := 0;
  process_end_date date := sysdate;

  CURSOR c_proc_org_s IS
    SELECT AMW_PROCESS_organization_s.NEXTVAL FROM dual;

  cursor get_counts is
    select nvl(risk_count,0) as risk_count,
          nvl(control_count,0) as control_count from amw_process
   where process_id=p_apo_type.process_id;

  l_risk_ctrl_count get_counts%rowtype;

begin
  savepoint insert_in_amwpo_pvt;

  l_process_id := p_apo_type.process_id;
  l_organization_id := p_apo_type.organization_id;

  ---------------------DBMS_OUTPUT.PUT_LINE ( 'top_process id: '|| p_apo_type.top_process_id);

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  if p_do_insert = 'INSERT' then
    open c_proc_org_s;
      fetch c_proc_org_s into l_process_organization_id;
    close c_proc_org_s;

    insert into AMW_process_organization(
     control_count,
     risk_count,
     top_process_id,
      process_organization_id,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     creation_date,
     created_by,
     LAST_UPDATE_LOGIN,
     process_id,
     standard_process_flag,
     risk_category,
     approval_status,
     certification_status,
     last_audit_status,
     organization_id,
     last_certification_date,
     last_audit_date,
     next_audit_date,
     application_owner_id,
     process_owner_id,
     process_category_code,
     significant_process_flag,
     finance_owner_id,
     created_from,
     request_id,
     program_application_id,
     program_id,
     program_update_date,
     attribute_category,
     attribute1,
     attribute2,
     attribute3,
     attribute4,
     attribute5,
     attribute6,
     attribute7,
     attribute8,
     attribute9,
     attribute10,
     attribute11,
     attribute12,
     attribute13,
     attribute14,
     attribute15,
     security_group_id,
     object_version_number,
     end_date) values(
     p_apo_type.control_count,
     p_apo_type.risk_count,
     p_apo_type.top_process_id,
      l_process_organization_id,
     sysdate,
     G_USER_ID,
     sysdate,
     G_USER_ID,
     G_LOGIN_ID,
     p_apo_type.process_id,
     decode(p_apo_type.standard_process_flag,null,'Y',p_apo_type.standard_process_flag),
     decode(p_apo_type.risk_category,null,'High',p_apo_type.risk_category),
     p_apo_type.approval_status,
     p_apo_type.certification_status,
     p_apo_type.last_audit_status,
     p_apo_type.organization_id,
     p_apo_type.last_certification_date,
     p_apo_type.last_audit_date,
     p_apo_type.next_audit_date,
     p_apo_type.application_owner_id,
     p_apo_type.process_owner_id,
     p_apo_type.process_category_code,
     p_apo_type.significant_process_flag,
     p_apo_type.finance_owner_id,
     p_apo_type.created_from,
     p_apo_type.request_id,
     p_apo_type.program_application_id,
     p_apo_type.program_id,
     p_apo_type.program_update_date,
     p_apo_type.attribute_category,
     p_apo_type.attribute1,
     p_apo_type.attribute2,
     p_apo_type.attribute3,
     p_apo_type.attribute4,
     p_apo_type.attribute5,
     p_apo_type.attribute6,
     p_apo_type.attribute7,
     p_apo_type.attribute8,
     p_apo_type.attribute9,
     p_apo_type.attribute10,
     p_apo_type.attribute11,
     p_apo_type.attribute12,
     p_apo_type.attribute13,
     p_apo_type.attribute14,
     p_apo_type.attribute15,
     p_apo_type.security_group_id,
     1,
     null
    );

   --Amit's requirement to increment org_count in amw_process for every associate
   select nvl(object_version_number,1) into l_obj_num from amw_process where process_id=p_apo_type.process_id;
   l_obj_num := l_obj_num+1;

   select nvl(org_count,0) into l_org_count from amw_process where process_id=p_apo_type.process_id;
   l_org_count := l_org_count+1;

/*    update amw_process set org_count=l_org_count,
    object_version_number=l_obj_num,
    last_update_date=sysdate,last_updated_by=G_USER_ID,last_update_login=G_LOGIN_ID
    where process_id=p_apo_type.process_id; */

   ---DBMS_OUTPUT.PUT_LINE('update amw_process set org_count=decode('||l_org_count||',null,1,'||l_org_count||'),last_update_date='||sysdate||',last_updated_by='||G_USER_ID||' where process_id='||p_apo_type.process_id);
  elsif p_do_insert = 'UPDATE' then
    --record already exists in some process hierarchy in amw_process_organization
   --so, do not insert, just update with top_process_id,end_date set to null
   select nvl(object_version_number,1) into l_obj_num from amw_process_organization
   where process_id=p_apo_type.process_id and organization_id=p_apo_type.organization_id;

   l_obj_num := l_obj_num+1;

   select end_date into process_end_date from amw_process_organization
    where process_id=p_apo_type.process_id
      and organization_id=p_apo_type.organization_id;

   open get_counts;
      fetch get_counts into l_risk_ctrl_count;
    close get_counts;

    update amw_process_organization
      set top_process_id=p_apo_type.top_process_id,
          risk_count=l_risk_ctrl_count.risk_count,
         control_count=l_risk_ctrl_count.control_count,
          object_version_number=l_obj_num,
          end_date=null,
          last_updated_by=G_USER_ID,
          last_update_date=sysdate,
          last_update_login=G_LOGIN_ID
    where process_id=p_apo_type.process_id and organization_id=p_apo_type.organization_id;

   --Amit's requirement to increment org_count in amw_process for every associate
   --check first to see if this process was already assigned to this org
   --and is active

   if(process_end_date is not null)then
     --this means that tbis process may have not been assigned to this org,
     --or, if assigned, may have been end-dated ....
       select nvl(object_version_number,1) into l_obj_num from amw_process where process_id=p_apo_type.process_id;
     l_obj_num := l_obj_num+1;

     select nvl(org_count,0) into l_org_count from amw_process where process_id=p_apo_type.process_id;
     l_org_count := l_org_count+1;

/*      update amw_process
        set org_count=l_org_count,
            object_version_number=l_obj_num,
            last_update_date=sysdate,
           last_updated_by=G_USER_ID,
           last_update_login=G_LOGIN_ID
      where process_id=p_apo_type.process_id; */
    end if;
   --------------------DBMS_OUTPUT.PUT_LINE ( 'updated amw_process_organization, p_org_id: '||l_process_organization_id ||', updated amw_process for process_id: '|| p_apo_type.process_id);

  elsif p_do_insert = 'DELETE' then
    l_org_count := p_org_count-1;
   l_assoc_mode := 'DISASSOCIATE';

   select nvl(object_version_number,1) into l_obj_num from amw_process_organization
   where process_id=p_apo_type.process_id and organization_id=p_apo_type.organization_id;

   l_obj_num := l_obj_num+1;

   update amw_process_organization
      set end_date=sysdate,
          object_version_number=l_obj_num,
         risk_count=0,
         control_count=0,
          last_updated_by=G_USER_ID,
          last_update_date=sysdate
    where process_id=p_apo_type.process_id and organization_id=p_apo_type.organization_id;

   --Amit's requirement to increment org_count in amw_process for every associate
    select nvl(object_version_number,1) into l_obj_num from amw_process where process_id=p_apo_type.process_id;
   l_obj_num := l_obj_num+1;

   select nvl(org_count,0) into l_org_count from amw_process where process_id=p_apo_type.process_id;
   if(l_org_count > 0)then
     l_org_count := l_org_count-1;
   end if;

/*   update amw_process
      set org_count=l_org_count,
          object_version_number=l_obj_num,
         last_updated_by=G_USER_ID,
         last_update_date=sysdate,
         last_update_login=G_LOGIN_ID
    where process_id=p_apo_type.process_id; */
  end if;

  ---DBMS_OUTPUT.PUT_LINE(FND_API.to_Boolean(p_commit));
  -- Standard check for p_commit
  IF FND_API.to_Boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;


  x_return_status := FND_API.G_RET_STS_SUCCESS;

  select process_organization_id into l_process_organization_id from amw_process_organization
  where process_id=p_apo_type.process_id and organization_id=p_apo_type.organization_id;

  ---passing for the financial statements modification as required by Qingdi
  process_amw_acct_assoc(
    p_assoc_mode => l_assoc_mode,
    p_process_id => p_apo_type.process_id,
    p_process_organization_id => l_process_organization_id,
   p_commit => p_commit,
   p_validation_level => p_validation_level,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
  );

fnd_file.put_line(fnd_file.LOG, 'INSIDE PROCESS_AMW_PROCESS_ORG');
    fnd_file.put_line(fnd_file.LOG, 'p_rcm_assoc: '||p_rcm_assoc);
    fnd_file.put_line(fnd_file.LOG, 'p_batch_id: '||p_batch_id);
    fnd_file.put_line(fnd_file.LOG, 'p_risk_id: '||p_risk_id);
    fnd_file.put_line(fnd_file.LOG, 'p_control_id: '||p_control_id);
    fnd_file.put_line(fnd_file.LOG, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

    if(p_rcm_assoc = 'Y')then
       fnd_file.put_line(fnd_file.LOG, 'WILL BE CALLING THE NEW API HERE');
	   process_amw_rcm_org(
	      p_batch_id	   			  => p_batch_id,
		  p_rcm_org_intf_id			  => p_rcm_org_intf_id,
          p_process_organization_id   => l_process_organization_id,
          p_organization_id 		  => p_apo_type.organization_id,
	      p_process_id 				  => p_apo_type.process_id,
          p_risk_id 				  => p_risk_id,
          p_control_id 				  => p_control_id,
	      p_commit 					  => p_commit,
	      p_validation_level 		  => p_validation_level,
          x_return_status 			  => x_return_status,
          x_msg_count 				  => x_msg_count,
          x_msg_data 				  => x_msg_data);

       fnd_file.put_line(fnd_file.LOG, 'PROCESS_AMW_RCM_ORG END: X_RETURN_STATUS: '||X_RETURN_STATUS);
    else
       fnd_file.put_line(fnd_file.LOG, 'CALLING THE old API HERE');
       process_amw_risk_assoc(
          p_assoc_mode => l_assoc_mode,
          p_process_id => p_apo_type.process_id,
          p_process_organization_id => l_process_organization_id,
          p_commit => p_commit,
          p_validation_level => p_validation_level,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data);
   end if;

  ----------------------dbms_output.put_line('Process_AMW_Process_Org x_return_status: '||x_return_status);
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Debug Message
  AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' end');

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count => x_msg_count,
    p_data => x_msg_data
  );

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO insert_in_amwpo_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO insert_in_amwpo_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO insert_in_amwpo_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
end process_amw_process_org;

procedure process_amw_rcm_org(
    p_batch_id in number := null,
	p_rcm_org_intf_id in number := null,
    p_process_organization_id in number := null,
    p_organization_id in number := null,
	p_process_id in number := null,
    p_risk_id in number := null,
    p_control_id in number := null,
	p_commit in varchar2 := FND_API.G_FALSE,
	p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
	p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status out nocopy varchar2,
    x_msg_count out nocopy number,
    x_msg_data out nocopy varchar2
  )

is
   cursor c1(p_batch_id in number, p_rcm_org_intf_id in number) is
      select risk_likelihood_code,
	         risk_impact_code,
			 upper(material) as material,
			 decode(nvl(upper(material),'N'),'N',null,material_value) as material_value
	    from amw_rcm_org_interface
	   where batch_id=p_batch_id
	     and rcm_org_interface_id=p_rcm_org_intf_id;

   cursor c2(p_batch_id in number, p_rcm_org_intf_id in number) is
      select ap_name,
	         upper(nvl(design_effectiveness,'N')) as design_effectiveness,
			 upper(nvl(op_effectiveness,'N')) as op_effectiveness
        from amw_rcm_org_interface
	   where batch_id=p_batch_id
	     and rcm_org_interface_id=p_rcm_org_intf_id;

   l_c1_type c1%rowtype;
   l_c2_type c2%rowtype;
   l_risk_association_id      NUMBER;
   l_CONTROL_association_id   NUMBER;
   L_API_NAME        CONSTANT VARCHAR2(30) := 'PROCESS_AMW_RCM_ORG';
begin
  IF FND_GLOBAL.User_Id IS NULL THEN
     AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  fnd_file.PUT_LINE( fnd_file.LOG, '%^&%^&%^&%^&%^&%^&%^&%^&%^&%^&%^&%^&%^&%^&%^&%^&%^&%^&');
  fnd_file.PUT_LINE( fnd_file.LOG, 'INSIDE PROCESS_AMW_RCM_ORG');
  fnd_file.put_line( fnd_file.Log, 'VALUES GOT --> ');
  fnd_file.PUT_LINE( fnd_file.LOG, 'p_batch_id: '||p_batch_id );
  fnd_file.PUT_LINE( fnd_file.LOG, 'p_rcm_org_intf_id: '||p_rcm_org_intf_id );
  fnd_file.PUT_LINE( fnd_file.LOG, 'p_process_organization_id: '||p_process_organization_id );
  fnd_file.PUT_LINE( fnd_file.LOG, 'p_organization_id: '||p_organization_id );
  fnd_file.PUT_LINE( fnd_file.LOG, 'p_process_id: '||p_process_id );
  fnd_file.PUT_LINE( fnd_file.LOG, 'p_risk_id: '||p_risk_id );
  fnd_file.PUT_LINE( fnd_file.LOG, 'p_batch_id: '||p_batch_id );
  fnd_file.PUT_LINE( fnd_file.LOG, 'p_control_id: '||p_control_id );

  begin
     select risk_association_id
       into l_risk_association_id
       from amw_risk_associations
      where object_type='PROCESS_ORG'
	    and pk1=p_process_organization_id
	    and risk_id=p_risk_id;

     open c1(p_batch_id,p_rcm_org_intf_id);
		fetch c1 into l_c1_type;
	 close c1;
     fnd_file.put_line(fnd_file.LOG, 'After Select, l_risk_association_id: '||l_risk_association_id);
     fnd_file.put_line(fnd_file.LOG, 'UPDATING AMW_RISK_ASSOCIATIONS');
	 UPDATE AMW_RISK_ASSOCIATIONS
	    SET OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
		   ,RISK_LIKELIHOOD_CODE=L_C1_TYPE.RISK_LIKELIHOOD_CODE
		   ,RISK_IMPACT_CODE=L_C1_TYPE.RISK_IMPACT_CODE
		   ,MATERIAL=L_C1_TYPE.MATERIAL
		   ,MATERIAL_VALUE=L_C1_TYPE.MATERIAL_VALUE
		   ,LAST_UPDATE_DATE=SYSDATE
		   ,LAST_UPDATED_BY=G_USER_ID
		   ,LAST_UPDATE_LOGIN=G_LOGIN_ID
	  WHERE RISK_ASSOCIATION_ID=L_RISK_ASSOCIATION_ID;

	  fnd_file.put_line(fnd_file.LOG, 'UPDATED AMW_RISK_ASSOCIATIONS');

  exception
     when no_data_found then
	    fnd_file.put_line(fnd_file.LOG, 'INSIDE NO_DATA_FOUND');
	    select amw_risk_associations_s.nextval into l_risk_association_id from dual;

		open c1(p_batch_id,p_rcm_org_intf_id);
		   fetch c1 into l_c1_type;
		close c1;

		fnd_file.put_line(fnd_file.LOG, 'VALUES TO BE INSERTED INTO AMW_RISK_ASSOCIATIONS');
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'risk_association_id: '||l_risk_association_id);
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'risk_id: '||p_risk_id);
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'pk1: '||p_process_organization_id);
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'risk_likelihood_code: '||l_c1_type.risk_likelihood_code);
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'risk_IMPACT_code: '||l_c1_type.risk_IMPACT_code);
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'MATERIAL: '||l_c1_type.material);
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'material_value: '||l_c1_type.material_value);

	    insert into amw_risk_associations(risk_association_id,
		                                  last_update_date,
										  last_updated_by,
										  creation_date,
										  created_by,
										  last_update_login,
										  risk_id,
										  pk1,
										  object_type,
										  object_version_number,
										  effective_date_from,
										  risk_likelihood_code,
										  risk_impact_code,
										  material,
										  material_value) values (
										  ---amw_risk_associations_s.nextval,
										  l_risk_association_id,
										  sysdate,
										  G_USER_ID,
										  sysdate,
										  G_USER_ID,
										  G_LOGIN_ID,
										  p_risk_id,
										  p_process_organization_id,
										  'PROCESS_ORG',
										  1,
										  sysdate,
										  l_c1_type.risk_likelihood_code,
										  l_c1_type.risk_impact_code,
										  l_c1_type.material,
										  l_c1_type.material_value);
  end;
  fnd_file.PUT_LINE( fnd_file.LOG, 'l_risk_association_id: '||l_risk_association_id);

  if(p_control_id is not null) then
     FND_FILE.PUT_LINE( FND_FILE.LOG, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' );
     FND_FILE.PUT_LINE( FND_FILE.LOG, 'DOING CONTROL ASSOCIATIONS HERE' );
     begin
        select CONTROL_association_id
          into l_CONTROL_association_id
          from amw_CONTROL_associations
         where object_type='RISK_ORG'
	       and pk1=l_risk_association_id
	       and CONTROL_id=p_CONTROL_id;

     fnd_file.put_line(fnd_file.LOG, 'After Select, l_CONTROL_association_id: '||l_CONTROL_association_id);

     exception
        when no_data_found then
		   fnd_file.put_line(fnd_file.LOG, 'INSIDE NO_DATA_FOUND');
	       select amw_CONTROL_associations_s.nextval into l_CONTROL_association_id from dual;

		   fnd_file.put_line(fnd_file.LOG, 'VALUES TO BE INSERTED INTO AMW_CONTROL_ASSOCIATIONS');
		   FND_FILE.PUT_LINE(FND_FILE.LOG, 'CONTROL_association_id: '||l_CONTROL_association_id);
		   FND_FILE.PUT_LINE(FND_FILE.LOG, 'CONTROL_id: '||p_CONTROL_id);
		   FND_FILE.PUT_LINE(FND_FILE.LOG, 'pk1: '||l_risk_association_id);

		   insert into amw_CONTROL_associations(CONTROL_association_id,
		                                  last_update_date,
										  last_updated_by,
										  creation_date,
										  created_by,
										  last_update_login,
										  CONTROL_id,
										  pk1,
										  object_type,
										  object_version_number,
										  effective_date_from) values (
										  ---amw_risk_associations_s.nextval,
										  l_CONTROL_association_id,
										  sysdate,
										  G_USER_ID,
										  sysdate,
										  G_USER_ID,
										  G_LOGIN_ID,
										  p_CONTROL_id,
										  l_risk_association_id,
										  'RISK_ORG',
										  1,
										  sysdate);
     end;
  else
     fnd_file.PUT_LINE( fnd_file.LOG, 'CANNOT DO CONTROL ASSOCIATIONS, BECAUSE CONTROL_ID IS NULL --> CONTROL_ID: '||P_CONTROL_ID);
  end if;

  /*
  open c2(p_batch_id,p_rcm_org_intf_id);
     fatch c2 into l_c2_type;
  close c2;
  */
  if(p_control_id is not null) then
     process_amw_ap_assoc(
        p_assoc_mode 	  	   	   => 'ASSOCIATE',
        p_control_association_id   => l_control_association_id,
        p_control_id 			   => P_control_id,
        p_commit 				   => p_commit,
        p_validation_level 		   => p_validation_level,
        x_return_status 		   => x_return_status,
        x_msg_count 			   => x_msg_count,
        x_msg_data 				   => x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);

end process_amw_rcm_org;

procedure process_amw_acct_assoc(
    p_assoc_mode in varchar2 := 'ASSOCIATE',
    p_process_id in number,
    p_process_organization_id in number,
    p_commit in varchar2 := FND_API.G_FALSE,
   p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
   x_return_status out nocopy varchar2,
    x_msg_count out nocopy number,
    x_msg_data out nocopy varchar2
    )
is
  L_API_NAME CONSTANT VARCHAR2(30) := 'Create_Acct_Assoc';
  L_API_VERSION_NUMBER CONSTANT NUMBER := 1.0;
  l_process_id number := p_process_id;
  l_process_organization_id number := p_process_organization_id;
  l_acct_assoc_id number := 0;

    cursor c1 is
    select acct_assoc_id,last_update_date,last_updated_by,
          creation_date,created_by,last_update_login,object_type,pk1,pk2,pk3,pk4,pk5,
         natural_account_id,statement_id,statement_line_id,attribute_category,
         attribute1,attribute2,attribute3,attribute4,
         attribute5,attribute6,attribute7,attribute8,attribute9,attribute10,
         attribute11,attribute12,---attribute13,
         attribute14,attribute15,
         security_group_id,object_version_number
    from amw_acct_associations
   where object_type='PROCESS'
     and pk1=l_process_id;
  l_aaa_row c1%rowtype;

  cursor c2 is
  select acct_assoc_id,natural_account_id
  from amw_acct_associations where object_type='PROCESS_ORG'
  and pk1=l_process_organization_id; ---and risk_id=;
  l_update c2%rowtype;

  row_count number := 0;

  x_rowid number;

  CURSOR c_id_exists (l_id IN NUMBER) IS
         SELECT 1
           FROM amw_acct_associations
          WHERE acct_assoc_id = l_id;

begin
  savepoint assoc_acct_pvt;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  -------------------------dbms_output.put_line('In amw_risk_associations: p_assoc_mode: '||p_assoc_mode);
  -- =========================================================================
  -- Validate Environment
  -- =========================================================================
  IF FND_GLOBAL.User_Id IS NULL
  THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  if p_assoc_mode = 'ASSOCIATE' then
    open c1;
      loop
        fetch c1 into l_aaa_row;
        exit when c1%notfound;

       select count(*) into row_count from amw_acct_associations
         where object_type='PROCESS_ORG'
         and pk1=l_process_organization_id
         and natural_account_id=l_aaa_row.natural_account_id;

      ----------------dbms_output.put_line('In amw_risk_associations: row_count: '||row_count);
      ---------------dbms_output.put_line('In amw_risk_associations: pk1: '||l_process_organization_id);
      --------------dbms_output.put_line('In amw_risk_associations: risk_id: '||l_ara_row.risk_id);

       if row_count = 0 then
          select amw_acct_associations_s.nextval into l_acct_assoc_id from dual;

        --------------------dbms_output.put_line('In amw_risk_associations: inserting');

        insert into amw_acct_associations (acct_assoc_id,last_update_date,
                                           last_updated_by,creation_date,created_by,
                                           last_update_login,object_type,pk1,pk2,pk3,pk4,pk5,
                                           natural_account_id,statement_id,statement_line_id,
                                 attribute_category,attribute1,attribute2,
                                           attribute3,attribute4,attribute5,attribute6,attribute7,
                                           attribute8,attribute9,attribute10,attribute11,attribute12,
                                           ---attribute13,
                                 attribute14,attribute15,security_group_id,
                                           object_version_number) values
                                          (l_acct_assoc_id,sysdate,G_USER_ID,sysdate,G_USER_ID,
                                           G_LOGIN_ID,'PROCESS_ORG',l_process_organization_id,l_aaa_row.pk2,
                                           l_aaa_row.pk3,l_aaa_row.pk4,l_aaa_row.pk5,l_aaa_row.natural_account_id,
                                 l_aaa_row.statement_id,l_aaa_row.statement_line_id,l_aaa_row.attribute_category,
                                           l_aaa_row.attribute1,l_aaa_row.attribute2,l_aaa_row.attribute3,l_aaa_row.attribute4,
                                           l_aaa_row.attribute5,l_aaa_row.attribute6,l_aaa_row.attribute7,l_aaa_row.attribute8,
                                           l_aaa_row.attribute9,l_aaa_row.attribute10,l_aaa_row.attribute11,l_aaa_row.attribute12,
                                           ----l_aaa_row.attribute13,
                                 l_aaa_row.attribute14,l_aaa_row.attribute15,
                                           l_aaa_row.security_group_id,1);

        open c_id_exists(l_acct_assoc_ID);
            fetch c_id_exists into X_ROWID;
          close c_id_exists;

        ---IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF X_ROWID is null THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

        -- Standard check for p_commit
          IF FND_API.to_Boolean( p_commit )
          THEN
            COMMIT WORK;
          END IF;
      end if;
      end loop;
    close c1;
  elsif p_assoc_mode = 'DISASSOCIATE' then
    open c2;
      loop
        fetch c2 into l_update;
        exit when c2%notfound;

      delete from amw_acct_associations
      where acct_assoc_id=l_update.acct_assoc_id
      and object_type='PROCESS_ORG'
      and pk1=p_process_organization_id;

      ---------------------dbms_output.put_line('In amw_risk_associations: deleting');

      -- Standard check for p_commit
        IF FND_API.to_Boolean( p_commit )
        THEN
          COMMIT WORK;
        END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      end loop;
   close c2;
  end if;

  -------------------dbms_output.put_line('Process_AMW_Risk_Assoc x_return_status: '||x_return_status);
  -- Debug Message
  ---AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
  AMW_UTILITY_PVT.debug_message(l_api_name || '_end');

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count => x_msg_count,
    p_data => x_msg_data
  );

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO assoc_acct_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO assoc_acct_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK TO assoc_acct_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);
end process_amw_acct_assoc;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Process_Amw_Risk_Assoc
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_assoc_mode              IN   VARCHAR2   Otional   Default = 'ASSOCIATE'
--       p_process_id              IN   number     Required
--       p_process_organization_id IN   number     Required
--       p_commit                  IN   VARCHAR2   Required  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:
--
--   End of Comments
--   ==============================================================================
--

procedure process_amw_risk_assoc(
    p_assoc_mode in varchar2 := 'ASSOCIATE',
    p_process_id in number,
    p_process_organization_id in number,
    p_commit in varchar2 := FND_API.G_FALSE,
   p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
   x_return_status out nocopy varchar2,
    x_msg_count out nocopy number,
    x_msg_data out nocopy varchar2
    )
is
  L_API_NAME CONSTANT VARCHAR2(30) := 'Create_Risk_Assoc';
  L_API_VERSION_NUMBER CONSTANT NUMBER := 1.0;
  l_process_id number := p_process_id;
  l_process_organization_id number := p_process_organization_id;
  l_risk_association_id number := 0;

    cursor c1 is
    select risk_association_id,last_update_date,last_updated_by,
          creation_date,created_by,last_update_login,risk_id,pk1,pk2,pk3,pk4,pk5,
         object_type,attribute_category,attribute1,attribute2,attribute3,attribute4,
         attribute5,attribute6,attribute7,attribute8,attribute9,attribute10,
         attribute11,attribute12,attribute13,attribute14,attribute15,
         security_group_id,object_version_number,effective_date_from,
         effective_date_to,risk_likelihood_code,risk_impact_code
		 ---added by npanandi on 01/22/2004 for 3362371 bug fix
		 ,material,material_value
		 ---finished addition on 01/22/2004
    from amw_risk_associations
   where object_type='PROCESS'
     and pk1=l_process_id;
  l_ara_row c1%rowtype;

  cursor c2 is
  select risk_association_id,risk_id
  from amw_risk_associations where object_type='PROCESS_ORG'
  and pk1=l_process_organization_id; ---and risk_id=;
  l_update c2%rowtype;

  row_count number := 0;

begin
  savepoint assoc_risk_pvt;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  -------------------------dbms_output.put_line('In amw_risk_associations: p_assoc_mode: '||p_assoc_mode);
  -- =========================================================================
  -- Validate Environment
  -- =========================================================================
  IF FND_GLOBAL.User_Id IS NULL
  THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  if p_assoc_mode = 'ASSOCIATE' then
    open c1;
      loop
        fetch c1 into l_ara_row;
        exit when c1%notfound;

       select count(*) into row_count from amw_risk_associations
         where object_type='PROCESS_ORG'
         and pk1=l_process_organization_id
         and risk_id=l_ara_row.risk_id;

      ----------------dbms_output.put_line('In amw_risk_associations: row_count: '||row_count);
      ---------------dbms_output.put_line('In amw_risk_associations: pk1: '||l_process_organization_id);
      --------------dbms_output.put_line('In amw_risk_associations: risk_id: '||l_ara_row.risk_id);

       if row_count = 0 then
          select amw_risk_associations_s.nextval into l_risk_association_id from dual;

        --------------------dbms_output.put_line('In amw_risk_associations: inserting');

        insert into amw_risk_associations (risk_association_id,last_update_date,
                                           last_updated_by,creation_date,created_by,
                                           last_update_login,risk_id,pk1,pk2,pk3,pk4,pk5,
                                           object_type,attribute_category,attribute1,attribute2,
                                           attribute3,attribute4,attribute5,attribute6,attribute7,
                                           attribute8,attribute9,attribute10,attribute11,attribute12,
                                           attribute13,attribute14,attribute15,security_group_id,
                                           object_version_number,effective_date_from,effective_date_to,
                                           risk_likelihood_code,risk_impact_code
										   ---added by npanandi on 01/22/2004 for 3362371 bug fix
										   ,material,material_value
										   ---finished addition on 01/22/2004
										   ) values
                                          (l_risk_association_id,sysdate,G_USER_ID,sysdate,G_USER_ID,
                                           G_LOGIN_ID,l_ara_row.risk_id,l_process_organization_id,l_ara_row.pk2,
                                           l_ara_row.pk3,l_ara_row.pk4,l_ara_row.pk5,'PROCESS_ORG',l_ara_row.attribute_category,
                                           l_ara_row.attribute1,l_ara_row.attribute2,l_ara_row.attribute3,l_ara_row.attribute4,
                                           l_ara_row.attribute5,l_ara_row.attribute6,l_ara_row.attribute7,l_ara_row.attribute8,
                                           l_ara_row.attribute9,l_ara_row.attribute10,l_ara_row.attribute11,l_ara_row.attribute12,
                                           l_ara_row.attribute13,l_ara_row.attribute14,l_ara_row.attribute15,
                                           l_ara_row.security_group_id,1,
                                           l_ara_row.effective_date_from,l_ara_row.effective_date_to,
                                           l_ara_row.risk_likelihood_code,l_ara_row.risk_impact_code
										   ---added by npanandi on 01/22/2004 for 3362371 bug fix
										   ,l_ara_row.material,l_ara_row.material_value
										   ---finished addition on 01/22/2004
										   );
        -- Standard check for p_commit
          IF FND_API.to_Boolean( p_commit )
          THEN
            COMMIT WORK;
          END IF;

          x_return_status := FND_API.G_RET_STS_SUCCESS;

          process_amw_control_assoc(
            p_assoc_mode => p_assoc_mode,
            p_risk_association_id => l_risk_association_id,
            p_risk_id => l_ara_row.risk_id,
            p_commit => p_commit,
              p_validation_level => p_validation_level,
            x_return_status => x_return_status,
              x_msg_count => x_msg_count,
              x_msg_data => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
      end if;
      end loop;
    close c1;
  elsif p_assoc_mode = 'DISASSOCIATE' then
    open c2;
      loop
        fetch c2 into l_update;
        exit when c2%notfound;

      delete from amw_risk_associations
      where risk_association_id=l_update.risk_association_id
      and object_type='PROCESS_ORG'
      and pk1=p_process_organization_id;

      ---------------------dbms_output.put_line('In amw_risk_associations: deleting');

      -- Standard check for p_commit
        IF FND_API.to_Boolean( p_commit )
        THEN
          COMMIT WORK;
        END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

        process_amw_control_assoc(
        p_assoc_mode => p_assoc_mode,
        p_risk_association_id => l_update.risk_association_id,
        p_risk_id => l_update.risk_id,
        p_commit => p_commit,
          p_validation_level => p_validation_level,
        x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      end loop;
   close c2;
  end if;

  -------------------dbms_output.put_line('Process_AMW_Risk_Assoc x_return_status: '||x_return_status);
  -- Debug Message
  AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count => x_msg_count,
    p_data => x_msg_data
  );

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO assoc_risk_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO assoc_risk_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK TO assoc_risk_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);
end process_amw_risk_assoc;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Process_Amw_Control_Assoc
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_assoc_mode              IN   VARCHAR2   Otional   Default = 'ASSOCIATE'
--       p_risk_association_id     IN   number     Required
--       p_risk_id                 IN   number     Required
--       p_commit                  IN   VARCHAR2   Required  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:
--
--   End of Comments
--   ==============================================================================
--

procedure process_amw_control_assoc(
    p_assoc_mode in varchar2 := 'ASSOCIATE',
    p_risk_association_id in number,
    p_risk_id in number,
    p_commit in varchar2 := FND_API.G_FALSE,
   p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
   x_return_status out nocopy varchar2,
    x_msg_count out nocopy number,
    x_msg_data out nocopy varchar2
    )
is
  L_API_NAME CONSTANT VARCHAR2(30) := 'Create_Control_Assoc';
  L_API_VERSION_NUMBER CONSTANT NUMBER := 1.0;
  l_risk_id number := p_risk_id;
  l_risk_association_id number := p_risk_association_id;
  l_control_association_id number := 0;

  cursor c1 is
    select control_association_id,last_update_date,last_updated_by,
          creation_date,created_by,last_update_login,control_id,pk1,pk2,pk3,pk4,pk5,
         object_type,attribute_category,attribute1,attribute2,attribute3,attribute4,
         attribute5,attribute6,attribute7,attribute8,attribute9,attribute10,
         attribute11,attribute12,attribute13,attribute14,attribute15,
         security_group_id,object_version_number,effective_date_from,
         effective_date_to
    from amw_control_associations
   where object_type='RISK' and pk1=l_risk_id;
  l_aca_row c1%rowtype;

  cursor c2 is
    select control_association_id,control_id
    from amw_control_associations where object_type='RISK_ORG'
    and pk1=l_risk_association_id; ---and risk_id=;
  l_update c2%rowtype;

  row_count number := 0;

begin
  savepoint assoc_control_pvt;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- =========================================================================
  -- Validate Environment
  -- =========================================================================
  IF FND_GLOBAL.User_Id IS NULL
  THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  if p_assoc_mode = 'ASSOCIATE' then
    open c1;
      loop
        fetch c1 into l_aca_row;
        exit when c1%notfound;
        select count(*) into row_count from amw_control_associations
           where object_type='RISK_ORG'
           and pk1=l_risk_association_id
           and control_id=l_aca_row.control_id;

         if row_count = 0 then
            select amw_control_associations_s.nextval into l_control_association_id from dual;

           -----------------dbms_output.put_line('INSERTING IN AMW_CONTROL_ASSOCIATIONS');
         ----------------------dbms_output.put_line('control_association_id: '||l_control_association_id);
          insert into amw_control_associations(control_association_id,last_update_date,
                                           last_updated_by,creation_date,created_by,
                                           last_update_login,control_id,pk1,pk2,pk3,pk4,pk5,
                                           object_type,attribute_category,attribute1,attribute2,
                                           attribute3,attribute4,attribute5,attribute6,attribute7,
                                           attribute8,attribute9,attribute10,attribute11,attribute12,
                                           attribute13,attribute14,attribute15,security_group_id,
                                           object_version_number,effective_date_from,effective_date_to)
                                 values (l_control_association_id,sysdate,G_USER_ID,sysdate,G_USER_ID,
                                           G_LOGIN_ID,l_aca_row.control_id,l_risk_association_id,l_aca_row.pk2,
                                           l_aca_row.pk3,l_aca_row.pk4,l_aca_row.pk5,'RISK_ORG',l_aca_row.attribute_category,
                                           l_aca_row.attribute1,l_aca_row.attribute2,l_aca_row.attribute3,l_aca_row.attribute4,
                                           l_aca_row.attribute5,l_aca_row.attribute6,l_aca_row.attribute7,l_aca_row.attribute8,
                                           l_aca_row.attribute9,l_aca_row.attribute10,l_aca_row.attribute11,l_aca_row.attribute12,
                                           l_aca_row.attribute13,l_aca_row.attribute14,l_aca_row.attribute15,
                                           l_aca_row.security_group_id,1,
                                           l_aca_row.effective_date_from,l_aca_row.effective_date_to);
            -- Standard check for p_commit
            IF FND_API.to_Boolean( p_commit )
            THEN
              COMMIT WORK;
            END IF;

          x_return_status := FND_API.G_RET_STS_SUCCESS;

          ----------------dbms_output.put_line('GOING TO INSERT_IN_AMW_AP_ASSOC: '|| l_control_association_id);

          process_amw_ap_assoc(
            p_assoc_mode => p_assoc_mode,
            p_control_association_id => l_control_association_id,
            p_control_id => l_aca_row.control_id,
            p_commit => p_commit,
            p_validation_level => p_validation_level,
            x_return_status => x_return_status,
              x_msg_count => x_msg_count,
              x_msg_data => x_msg_data
          );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;
         end if;
      end loop;
    close c1;
  elsif p_assoc_mode = 'DISASSOCIATE' then
    open c2;
      loop
        fetch c2 into l_update;
        exit when c2%notfound;


        x_return_status := FND_API.G_RET_STS_SUCCESS;

        process_amw_ap_assoc(
        p_assoc_mode => p_assoc_mode,
        p_control_association_id => l_update.control_association_id,
        p_control_id => l_update.control_id,
        p_commit => p_commit,
        p_validation_level => p_validation_level,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
      );
      delete from amw_control_associations
      where control_association_id=l_update.control_association_id
      and object_type='RISK_ORG'
      and pk1=p_risk_association_id;


      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
        COMMIT WORK;
      END IF;
      end loop;
   close c2;
  end if;

 -------------------dbms_output.put_line('Process_AMW_Control_Assoc x_return_status: '||x_return_status);
  -- Debug Message
  AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count => x_msg_count,
    p_data => x_msg_data
  );

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO assoc_control_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO assoc_control_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK TO assoc_control_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);
end process_amw_control_assoc;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Process_Amw_Ap_Assoc
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_assoc_mode              IN   VARCHAR2   Otional   Default = 'ASSOCIATE'
--       p_control_association_id  IN   number     Required
--       p_control_id              IN   number     Required
--       p_commit                  IN   VARCHAR2   Required  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:
--
--   End of Comments
--   ==============================================================================
--

procedure process_amw_ap_assoc(
    p_assoc_mode in varchar2 := 'ASSOCIATE',
    p_control_association_id in number,
    p_control_id in number,
    p_commit in varchar2 := FND_API.G_FALSE,
    p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status out nocopy varchar2,
    x_msg_count out nocopy number,
    x_msg_data out nocopy varchar2
    )
is
  L_API_NAME CONSTANT VARCHAR2(30) := 'Create_AP_Assoc';
  L_API_VERSION_NUMBER CONSTANT NUMBER := 1.0;
  l_control_id number := p_control_id;
  l_control_association_id number := p_control_association_id;
  l_ap_association_id number := 0;

  cursor c1 is
    select ap_association_id,last_update_date,last_updated_by,
          creation_date,created_by,last_update_login,pk1,pk2,pk3,pk4,pk5,
         object_type,audit_procedure_id,attribute_category,attribute1,attribute2,
         attribute3,attribute4,attribute5,attribute6,attribute7,attribute8,
         attribute9,attribute10,attribute11,attribute12,attribute13,attribute14,
         attribute15,security_group_id,object_version_number,design_effectiveness,
         op_effectiveness
    from amw_ap_associations where object_type='CTRL' and pk1=l_control_id;
  l_aaa_row c1%rowtype;
/*
  cursor c2 is
    select ap_association_id,audit_procedure_id
    from amw_ap_associations where object_type='CTRL_ORG'
    and pk1=l_control_association_id; ---and risk_id=;
    */

  --mpande added 11/14/2003
  cursor c2 is
         select ap_association_id,audit_procedure_id
         from amw_process_organization apo, amw_risk_associations ara, amw_control_associations aca, amw_ap_associations apa
         where apo.process_organization_id = ara.pk1
         and ara.risk_association_id = aca.pk1
         and aca.control_association_id = p_control_association_id
         and apa.pk1  = apo.organization_id
         and apa.pk2 = apo.process_id
         and apa.pk3 = aca.control_id
         and apa.object_type='CTRL_ORG';


  l_update c2%rowtype;

  row_count number := 0;
  l_process_id number;
  l_org_id number;

begin
  savepoint assoc_ap_pvt;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- =========================================================================
  -- Validate Environment
  -- =========================================================================
  IF FND_GLOBAL.User_Id IS NULL
  THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;


   if p_assoc_mode = 'ASSOCIATE' then
   open c1;
      loop
        fetch c1 into l_aaa_row;
        exit when c1%notfound;

         select apo.process_id, apo.organization_id
         into l_process_id, l_org_id
         from amw_process_organization apo, amw_risk_associations ara, amw_control_associations aca
         where apo.process_organization_id = ara.pk1
         and ara.risk_association_id = aca.pk1
         and aca.control_association_id = p_control_association_id;



/*
**    select count(*) into row_count from amw_ap_associations
**    where object_type='CTRL_ORG'
**    and pk1=l_control_association_id
**    and audit_procedure_id=l_aaa_row.audit_procedure_id;
*/

          select count(*) into row_count from amw_ap_associations
          where object_type='CTRL_ORG'
          and pk1=l_org_id
          and pk2 = l_process_id
          and pk3 = p_control_id
          and audit_procedure_id=l_aaa_row.audit_procedure_id;


    if row_count = 0 then
            select amw_ap_associations_s.nextval into l_ap_association_id from dual;


            insert into amw_ap_associations(ap_association_id,last_update_date,
                                        last_updated_by,creation_date,created_by,
                                        last_update_login,pk1,pk2,pk3,pk4,pk5,object_type,
                                        audit_procedure_id,attribute_category,attribute1,attribute2,
                                        attribute3,attribute4,attribute5,attribute6,attribute7,
                                        attribute8,attribute9,attribute10,attribute11,attribute12,
                                        attribute13,attribute14,attribute15,security_group_id,
                                        object_version_number,design_effectiveness,op_effectiveness)
               values
               (l_ap_association_id,sysdate,G_USER_ID,sysdate,G_USER_ID,
                                        G_LOGIN_ID,l_org_id,l_process_id, p_control_id,
                                        l_aaa_row.pk4,l_aaa_row.pk5,'CTRL_ORG',l_aaa_row.audit_procedure_id,
               l_aaa_row.attribute_category,l_aaa_row.attribute1,l_aaa_row.attribute2,
               l_aaa_row.attribute3,l_aaa_row.attribute4,l_aaa_row.attribute5,l_aaa_row.attribute6,
               l_aaa_row.attribute7,l_aaa_row.attribute8,l_aaa_row.attribute9,l_aaa_row.attribute10,
               l_aaa_row.attribute11,l_aaa_row.attribute12,l_aaa_row.attribute13,l_aaa_row.attribute14,
               l_aaa_row.attribute15,l_aaa_row.security_group_id,1,
                                        l_aaa_row.design_effectiveness,l_aaa_row.op_effectiveness);

        -- Standard check for p_commit
          IF FND_API.to_Boolean( p_commit )
          THEN
            COMMIT WORK;
          END IF;
      end if;
      end loop;
    close c1;
  elsif p_assoc_mode = 'DISASSOCIATE' then
    open c2;
      loop
        fetch c2 into l_update;
        exit when c2%notfound;

         delete from amw_ap_associations
         where ap_association_id=l_update.ap_association_id ;
         -- commented by mpande
--         and object_type='CTRL_ORG' ;
--         and pk1=p_control_association_id;

      -- Standard check for p_commit
        IF FND_API.to_Boolean( p_commit )
        THEN
          COMMIT WORK;
        END IF;

      end loop;
   close c2;
  end if;

   -----------------------dbms_output.put_line('Process_AMW_AP_Assoc x_return_status: '||x_return_status);
  -- Debug Message
  AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count => x_msg_count,
    p_data => x_msg_data
  );

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO assoc_ap_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO assoc_ap_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK TO assoc_ap_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);
end process_amw_ap_assoc;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Process_Hierarchy_Count
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_process_id              IN   NUMBER     Optional  Default = null
--       p_organization_id         IN   NUMBER     Optional  Default = null
--       p_mode                    IN   VARCHAR2   Required  Default = 'ASSOCIATE'
--       p_apo_type                IN   apo_type   Optional  Default = null
--       p_commit                  IN   VARCHAR2   Required  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:
--
--   End of Comments
--   ==============================================================================
--

   PROCEDURE process_hierarchy_count (
      p_process_id                IN              NUMBER := NULL,
      p_organization_id           IN              NUMBER := NULL,
      p_risk_count              in           number := null,
     p_control_count           in           number := null,
     p_mode                     IN              VARCHAR2 := 'ASSOCIATE',
      p_commit                    IN              VARCHAR2 := fnd_api.g_false,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2
   ) IS

      l_api_name             CONSTANT VARCHAR2 (30) := 'process_hierarchy_count';
      l_api_version_number   CONSTANT NUMBER        := 1.0;
      x_process_organization_id       NUMBER        := 0;
      l_process_id                    NUMBER;

     --- this API will be called from the amw_proc_org_hierarchy_pvt
     --- For a given process, this API traverses all the upward processes
     --- in that Process hierarchy for that organization
    cursor c1 is
     select process_id,
            nvl(risk_count,0) as risk_count,
            nvl(control_count,0) as control_count,
            process_organization_id,object_version_number
        FROM amw_process_organization
       WHERE organization_id = p_organization_id AND process_id IN (
                   SELECT DISTINCT p2.process_id
                              FROM amw_process p1,
                                   amw_process p2,
                                   amw_process_organization apo1,
                                   amw_process_organization apo2,
                                   wf_activities wa
                             WHERE (p2.NAME, p2.item_type) IN (
                                      SELECT     activity_name,
                                                 activity_item_type
                                            FROM wf_process_activities
                                      CONNECT BY activity_name = PRIOR process_name
                                             AND activity_item_type = PRIOR process_item_type
                                      START WITH activity_name = p1.NAME
                                             AND activity_item_type = p1.item_type)
                               AND p2.NAME = wa.NAME
                               AND p2.item_type = wa.item_type
                               AND wa.end_date IS NULL
                               AND p2.process_id = apo2.process_id
                               AND apo2.organization_id = apo1.organization_id
                               AND p1.process_id = apo1.process_id
                               ---and apo1.process_id=142
                               AND apo1.process_id = p_process_id
                               AND apo1.organization_id = p_organization_id);

      assoc_risk c1%rowtype;
      -----find the control_count for this risk, and append this
     -----to all the control_counts of upward processes
BEGIN
       ---Inserting process_id
      SAVEPOINT process_hierarchy_count;
      x_return_status            := fnd_api.g_ret_sts_success;
      -- Standard call to check for call compatibility.

     -- Debug Message
      amw_utility_pvt.debug_message ('Private API: ' || l_api_name || ' start');

     -- Initialize API return status to SUCCESS
      x_return_status  := fnd_api.g_ret_sts_success;

     /* Temporarily commenting out the validata session code ..... */
        -- =========================================================================
        -- Validate Environment
        -- =========================================================================
      IF fnd_global.user_id IS NULL THEN
         amw_utility_pvt.error_message(p_message_name => 'USER_PROFILE_MISSING');
         RAISE fnd_api.g_exc_error;
      END IF;

      amw_wf_hierarchy_pkg.reset_proc_org_risk_ctrl_count;

      /*  Commented  by mpande 11/13/2003 bug#
      OPEN c1;
         LOOP
            FETCH c1
             INTO assoc_risk;
            EXIT WHEN c1%NOTFOUND;
            --increment risk count for associate


            --dbms_output.put_line('In the ''RISK'' mode');
         assoc_risk.object_version_number := assoc_risk.object_version_number+1;
         if(p_mode = 'ASSOCIATE')then
           assoc_risk.risk_count := assoc_risk.risk_count+p_risk_count;
           assoc_risk.control_count := assoc_risk.control_count+p_control_count;
         elsif(p_mode = 'DISASSOCIATE') then
           assoc_risk.risk_count := assoc_risk.risk_count-p_risk_count;
           assoc_risk.control_count := assoc_risk.control_count-p_control_count;
         end if;


         if(p_process_id <> assoc_risk.process_id or p_mode='DISASSOCIATE')then
             ---if(p_process_id=assoc_risk.process_id)then
              ---dbms_output.put_line('process_id '||p_process_id||' p_mode: '||p_mode);
            ---end if;
                --update amw_process' risk_count
                 UPDATE amw_process_organization
                  SET risk_count = assoc_risk.risk_count,
                  control_count = assoc_risk.control_count,
                      object_version_number = assoc_risk.object_version_number,
                      last_updated_by = g_user_id,
                      last_update_date = SYSDATE,
                      last_update_login = g_login_id
                WHERE process_organization_id = assoc_risk.process_organization_id;
         end if;

         END LOOP;
            CLOSE c1;

     -- =========================================================================
      -- End Validate Environment
      -- =========================================================================
      -- End commenting the session validation code ....
      */
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Standard check for p_commit
      IF fnd_api.to_boolean (p_commit) THEN
         COMMIT WORK;
      END IF;

      --Debug Message
      amw_utility_pvt.debug_message ('Private API: ' || l_api_name || ' end');
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                p_data => x_msg_data);

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO process_hierarchy_count;
         x_return_status            := fnd_api.g_ret_sts_error;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO process_hierarchy_count;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN OTHERS THEN
         ROLLBACK TO process_hierarchy_count;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
   END process_hierarchy_count;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_Apo_Type
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     REQUIRED
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_apo_type                IN   apo_type   Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE validate_apo_type(
    p_api_version_number IN NUMBER,
    p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_apo_type IN apo_type,
    x_return_status OUT nocopy VARCHAR2,
    x_msg_count OUT nocopy NUMBER,
    x_msg_data OUT nocopy VARCHAR2
    )
IS
  L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Process';
  L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
  l_object_version_number     NUMBER;
  --l_process_rec  AMW_Process_PVT.process_rec_type;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT validate_process_pvt;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version_number,p_api_version_number,l_api_name,G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
     FND_MSG_PUB.initialize;
  END IF;

  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
    check_apo_row(
      p_apo_type => p_apo_type,
      p_validation_mode => JTF_PLSQL_API.g_update,
      x_return_status => x_return_status
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  -- Debug Message
  AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Debug Message
  AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count => x_msg_count,
    p_data => x_msg_data
  );
EXCEPTION

   WHEN AMW_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Process_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Process_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Process_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End validate_apo_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Check_Apo_Row
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_apo_type                IN   apo_type   Required
--       p_validation_mode         IN   VARCHAR2   Optional  Default = JTF_PLSQL_API.g_create
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE check_apo_row(
  p_apo_type IN apo_type,
  p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
  x_return_status OUT nocopy VARCHAR2
)
IS

BEGIN
  x_return_status := FND_API.g_ret_sts_success;

  IF p_validation_mode = JTF_PLSQL_API.g_create THEN
    IF p_apo_type.organization_id = FND_API.g_miss_num OR p_apo_type.organization_id IS NULL THEN
      AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_process_organization_NO_organization_id');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;

    IF p_apo_type.process_id = FND_API.g_miss_num OR p_apo_type.process_id IS NULL THEN
      AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_process_NO_process_id');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;
END check_apo_row;

FUNCTION GET_parent_process_id(p_process_id in number,
                         p_organization_id in number) return number is


   cursor c1 is
           select aphv.parent_process_id,apo.end_date
           from   amw_process_hierarchy_v aphv,amw_process_organization apo
           where  aphv.child_process_id=p_process_id
        and    apo.process_id=p_process_id
        and     apo.organization_id=p_organization_id;

   l_ppid c1%rowtype;

   l_rpid number := -1;
   l_row_pid number := -1;

   l_api_name varchar2(30) := 'Get_Parent_Process_Id';

begin
   open c1;
   loop
   fetch c1 into l_ppid;
    exit when c1%notfound;
      ---dbms_output.put_line('l_ppid.parent_process_id: '||
      ----raise FND_API.G_EXC_ERROR;
      if(l_ppid.end_date is null)then
        l_rpid := l_ppid.parent_process_id;
       exit;
      end if;
      l_row_pid := l_ppid.parent_process_id;
   end loop;
   close c1;

   if(l_rpid = -1)then
     l_rpid := l_row_pid;
   end if;

   return l_rpid;

exception

  WHEN OTHERS THEN
  --   ROLLBACK TO assoc_ap_pvt;
    -- x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
    ----dbms_output.put_line('EXCEPTION');
    RAISE;
     -- Standard call to get message count and if count=1, get the message
--     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);
/*
    when no_data_found then
        return null;
    when others then

        return null;
      */
end GET_parent_process_id;

END AMW_PROC_ORG_HIERARCHY_PVT;

/
