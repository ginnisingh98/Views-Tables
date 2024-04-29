--------------------------------------------------------
--  DDL for Package Body PSB_COPY_DATA_EXTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_COPY_DATA_EXTRACT_PVT" AS
/* $Header: PSBVCDEB.pls 120.13 2006/08/21 05:15:42 maniskum ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_COPY_DATA_EXTRACT_PVT';

  g_dbug         VARCHAR2(2000);
  g_debug_flag   VARCHAR2(1) := 'N';

/* ----------------------------------------------------------------------- */

PROCEDURE debug
( p_message         IN  VARCHAR2) IS

BEGIN

  if g_debug_flag = 'Y' then
    null;
--  dbms_output.put_line(p_message);
  end if;

END debug;

/* ----------------------------------------------------------------------- */

PROCEDURE Copy_Attributes
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_extract_method      IN      VARCHAR2,
  p_src_data_extract_id IN      NUMBER,
  p_data_extract_id     IN      NUMBER
) AS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Copy_Attributes';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_last_update_date    date;
  l_last_updated_by     number;
  l_last_update_login   number;
  l_creation_date       date;
  l_created_by          number;
  lr_attribute_id       number;
  --UTF8 changes for Bug No : 2615261
  lr_attribute_value    psb_attribute_values.attribute_value%TYPE;
  l_attribute_value_id  number;
  l_attr_dummy          number := 0;
  l_rowid               varchar2(100);
  l_status              varchar2(1);
  l_return_status       varchar2(1);
  l_msg_count           number;
  l_msg_data            varchar2(1000);
  l_restart_id          number;

  Cursor C_Attr_Val is
    Select attribute_value_id,attribute_id,
	   attribute_value,hr_value_id,description
      from psb_attribute_values
     where data_extract_id = p_src_data_extract_id;

  Cursor C_ref_attr is
    Select attribute_value_id
      from psb_attribute_values
     where attribute_id = lr_attribute_id
       and attribute_value = lr_attribute_value
       and data_extract_id = p_data_extract_id;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT Copy_Attributes_Pvt;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
  l_last_update_date  := sysdate;
  l_last_updated_by   := FND_GLOBAL.USER_ID;
  l_last_update_login := FND_GLOBAL.LOGIN_ID;
  l_creation_date     := sysdate;
  l_created_by        := FND_GLOBAL.USER_ID;

  PSB_HR_EXTRACT_DATA_PVT.Check_Reentry
  (p_api_version              => 1.0  ,
   p_return_status            => l_return_status,
   p_msg_count                => l_msg_count,
   p_msg_data                 => l_msg_data,
   p_data_extract_id          => p_data_extract_id,
   p_process                  => 'Copy Attributes',
   p_status                   => l_status,
   p_restart_id               => l_restart_id
   );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  end if;

  if (l_status <> 'C') then
  For C_Attr_Val_Rec in C_Attr_Val
  Loop
       lr_attribute_id    := C_Attr_Val_Rec.attribute_id;
       lr_attribute_value := C_Attr_Val_Rec.attribute_value;

       For C_ref_attr_rec in C_ref_attr
       Loop
	l_attr_dummy := 1;
	  PSB_ATTRIBUTE_VALUES_PVT.UPDATE_ROW
	  ( p_api_version             =>  1.0,
	    p_init_msg_lISt           => NULL,
	    p_commit                  => NULL,
	    p_validation_level        => NULL,
	    p_return_status           => l_return_status,
	    p_msg_count               => l_msg_count,
	    p_msg_data                => l_msg_data,
	    p_attribute_value_id      => C_ref_attr_rec.attribute_value_id,
	    p_attribute_id            => C_Attr_Val_Rec.attribute_id,
	    p_attribute_value         => C_Attr_Val_Rec.attribute_value,
	    p_hr_value_id             => C_Attr_Val_Rec.hr_value_id,
	    p_description             => C_Attr_Val_Rec.description,
	    p_data_extract_id         => p_data_extract_id,
	    p_context                 => NULL,
	    p_attribute1              => NULL,
	    p_attribute2              => NULL,
	    p_attribute3              => NULL,
	    p_attribute4              => NULL,
	    p_attribute5              => NULL,
	    p_attribute6              => NULL,
	    p_attribute7              => NULL,
	    p_attribute8              => NULL,
	    p_attribute9              => NULL,
	    p_attribute10             => NULL,
	    p_attribute11             => NULL,
	    p_attribute12             => NULL,
	    p_attribute13             => NULL,
	    p_attribute14             => NULL,
	    p_attribute15             => NULL,
	    p_attribute16             => NULL,
	    p_attribute17             => NULL,
	    p_attribute18             => NULL,
	    p_attribute19             => NULL,
	    p_attribute20             => NULL,
	    p_attribute21             => NULL,
	    p_attribute22             => NULL,
	    p_attribute23             => NULL,
	    p_attribute24             => NULL,
	    p_attribute25             => NULL,
	    p_attribute26             => NULL,
	    p_attribute27             => NULL,
	    p_attribute28             => NULL,
	    p_attribute29             => NULL,
	    p_attribute30             => NULL,
	    p_last_update_date        => l_last_update_date,
	    p_last_updated_by         => l_last_updated_by,
	    p_last_update_login       => l_last_update_login
	  );

	if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   raise FND_API.G_EXC_ERROR;
	end if;
       End Loop;

       if (l_attr_dummy = 0)  then

       select psb_attribute_values_s.nextval into
	      l_attribute_value_id from dual;

       PSB_ATTRIBUTE_VALUES_PVT.INSERT_ROW
       ( p_api_version             =>  1.0,
	 p_init_msg_list           => null,
	 p_commit                  => null,
	 p_validation_level        => null,
	 p_return_status           => l_return_status,
	 p_msg_count               => l_msg_count,
	 p_msg_data                => l_msg_data,
	 p_rowid                   => l_rowid,
	 p_attribute_value_id      => l_attribute_value_id,
	 p_attribute_id            => C_Attr_Val_Rec.attribute_id,
	 p_attribute_value         => C_Attr_Val_Rec.attribute_value,
	 p_hr_value_id             => C_Attr_Val_Rec.hr_value_id,
	 p_description             => C_Attr_Val_Rec.description,
	 p_data_extract_id         => p_data_extract_id,
	 p_context                 => null,
	 p_attribute1              => null,
	 p_attribute2              => null,
	 p_attribute3              => null,
	 p_attribute4              => null,
	 p_attribute5              => null,
	 p_attribute6              => null,
	 p_attribute7              => null,
	 p_attribute8              => null,
	 p_attribute9              => null,
	 p_attribute10             => null,
	 p_attribute11             => null,
	 p_attribute12             => null,
	 p_attribute13             => null,
	 p_attribute14             => null,
	 p_attribute15             => null,
	 p_attribute16             => null,
	 p_attribute17             => null,
	 p_attribute18             => null,
	 p_attribute19             => null,
	 p_attribute20             => null,
	 p_attribute21             => null,
	 p_attribute22             => null,
	 p_attribute23             => null,
	 p_attribute24             => null,
	 p_attribute25             => null,
	 p_attribute26             => null,
	 p_attribute27             => null,
	 p_attribute28             => null,
	 p_attribute29             => null,
	 p_attribute30             => null,
	 p_last_update_date        => l_last_update_date,
	 p_last_updated_by         => l_last_updated_by,
	 p_last_update_login       => l_last_update_login,
	 p_created_by              => l_created_by,
	 p_creation_date           => l_creation_date
	) ;

	if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   debug('Insert Attribute Values Failed');
	   raise FND_API.G_EXC_ERROR;
	end if;

    end if;

  End Loop;

  PSB_HR_EXTRACT_DATA_PVT.Reentrant_Process
  ( p_api_version              => 1.0  ,
    p_return_status            => l_return_status,
    p_msg_count                => l_msg_count,
    p_msg_data                 => l_msg_data,
    p_data_extract_id          => p_data_extract_id,
    p_extract_method           => p_extract_method,
    p_process                  => 'Copy Attributes'
  );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     debug('Reentry Failed Copy Attributes');
     raise FND_API.G_EXC_ERROR;
  end if;
  end if;

  -- End of API body.

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to Copy_Attributes_Pvt;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Copy_Attributes_Pvt;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to Copy_Attributes_Pvt;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Copy_Attributes;

PROCEDURE Copy_Position_Sets
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_extract_method      IN      VARCHAR2,
  p_src_data_extract_id IN      NUMBER,
  p_data_extract_id     IN      NUMBER
) AS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Copy_Position_Sets';
  l_api_version         CONSTANT NUMBER         := 1.0;

  l_entity_tbl              PSB_Account_Position_Set_Pvt.Entity_Tbl_Type;
  l_return_status           varchar2(1);
  l_status                  varchar2(1);
  l_msg_count               number;
  l_msg_data                varchar2(1000);
  l_restart_id              number;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT Copy_Position_Sets_Pvt;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
  PSB_HR_EXTRACT_DATA_PVT.Check_Reentry
  (p_api_version              => 1.0  ,
   p_return_status            => l_return_status,
   p_msg_count                => l_msg_count,
   p_msg_data                 => l_msg_data,
   p_data_extract_id          => p_data_extract_id,
   p_process                  => 'Copy Position Sets',
   p_status                   => l_status,
   p_restart_id               => l_restart_id
   );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  end if;

  if (l_status <> 'C') then

  l_entity_tbl(1) := 'DR';
  l_entity_tbl(2) := 'E';
  l_entity_tbl(3) := 'PSG';

  PSB_Account_Position_Set_Pvt.Copy_Position_Sets
  (p_api_version              => 1.0  ,
   p_return_status            => l_return_status,
   p_msg_count                => l_msg_count,
   p_msg_data                 => l_msg_data,
   p_source_data_extract_id   => p_src_data_extract_id,
   p_target_data_extract_id   => p_data_extract_id,
   p_entity_table             => l_entity_tbl
  );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     debug('Copy Position Sets Failed');
     raise FND_API.G_EXC_ERROR;
  end if;

  PSB_HR_EXTRACT_DATA_PVT.Reentrant_Process
  ( p_api_version              => 1.0  ,
    p_return_status            => l_return_status,
    p_msg_count                => l_msg_count,
    p_msg_data                 => l_msg_data,
    p_data_extract_id          => p_data_extract_id,
    p_extract_method           => p_extract_method,
    p_process                  => 'Copy Position Sets'
  );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     debug('Reentry Failed Copy Position Sets');
     raise FND_API.G_EXC_ERROR;
  end if;

 end if;
  -- End of API body.

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to Copy_Position_Sets_Pvt;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Copy_Position_Sets_Pvt;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to Copy_Position_Sets_Pvt;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
END;

PROCEDURE Copy_Elements
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_extract_method      IN      VARCHAR2,
  p_src_data_extract_id IN      NUMBER,
  p_copy_salary_flag    IN      VARCHAR2,
  p_data_extract_id     IN      NUMBER
) AS

  l_api_name                CONSTANT VARCHAR2(30) := 'Copy_Elements';
  l_api_version             CONSTANT NUMBER       := 1.0;
  l_last_update_date        date;
  l_last_updated_by         number;
  l_last_update_login       number;
  l_element_dummy           number;
  l_element_name            varchar2(30);
  l_creation_date           date;
  l_created_by              number;
  l_status                  varchar2(1);
  l_return_status           varchar2(1);
  l_msg_count               number;
  l_msg_data                varchar2(1000);
  l_restart_id              number;

/* Bug No 2579818 Start */
  l_business_group_id       NUMBER;

  cursor c_extract is
    select business_group_id
      from PSB_DATA_EXTRACTS
     where data_extract_id = p_src_data_extract_id;
/* Bug No 2579818 End */

  Cursor l_find_element_csr is
    Select pay_element_id,
	   name,
	   salary_flag
     from psb_pay_elements
     where data_extract_id = p_src_data_extract_id;

  Cursor l_find_target_element_csr is
    Select pay_element_id
      from psb_pay_elements
     where name            = l_element_name
       and data_extract_id = p_data_extract_id;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT Copy_Elements_Pvt;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
  l_last_update_date  := sysdate;
  l_last_updated_by   := FND_GLOBAL.USER_ID;
  l_last_update_login := FND_GLOBAL.LOGIN_ID;
  l_creation_date     := sysdate;
  l_created_by        := FND_GLOBAL.USER_ID;

  PSB_HR_EXTRACT_DATA_PVT.Check_Reentry
  (p_api_version              => 1.0  ,
   p_return_status            => l_return_status,
   p_msg_count                => l_msg_count,
   p_msg_data                 => l_msg_data,
   p_data_extract_id          => p_data_extract_id,
   p_process                  => 'Copy Elements',
   p_status                   => l_status,
   p_restart_id               => l_restart_id
   );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  end if;

  if (l_status <> 'C') then

/* Bug No 2579818 Start */
  for c_extract_rec in c_extract loop
    l_business_group_id := c_extract_rec.business_group_id;
  end loop;

  PSB_POSITION_CONTROL_PVT.Upload_Attribute_Values
	(p_return_status => l_return_status,
	 p_source_data_extract_id => p_src_data_extract_id,
	 p_source_business_group_id => l_business_group_id,
	 p_target_data_extract_id => p_data_extract_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;
/* Bug No 2579818 End */


    For l_find_element_rec in l_find_element_csr
    Loop

      l_element_dummy := 0;

	if (l_find_element_rec.salary_flag = 'Y') then
	  if (p_copy_salary_flag = 'Y') then
	    if (p_extract_method = 'REFRESH') then

	      l_element_name  := l_find_element_rec.name;

		For l_find_target_element_rec in l_find_target_element_csr
		Loop

		  l_element_dummy := 1;

		End Loop;
	     end if;
	   else

	     l_element_dummy := 1;

	   end if;
	else

	  l_element_name  := l_find_element_rec.name;

	  For l_find_target_element_rec in l_find_target_element_csr
	  Loop

	     l_element_dummy := 1;

	  End Loop;
	end if;

	if (l_element_dummy = 0) then

	PSB_POSITION_CONTROL_PVT.Upload_Element
	   (p_return_status => l_return_status,
	    p_source_data_extract_id => p_src_data_extract_id,
	    p_target_data_extract_id => p_data_extract_id,
	    p_pay_element_id => l_find_element_rec.pay_element_id);

	  if l_return_status = FND_API.G_RET_STS_ERROR then
	    debug('Copy Entity Elements Failed');
	    raise FND_API.G_EXC_ERROR;
	  elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
	    debug('Copy Entity Elements Failed');
	    raise FND_API.G_EXC_UNEXPECTED_ERROR ;
	  end if;

	  end if; -- element_dummy value check
    End Loop;

	PSB_HR_EXTRACT_DATA_PVT.Reentrant_Process
	( p_api_version              => 1.0  ,
	  p_return_status            => l_return_status,
	  p_msg_count                => l_msg_count,
	  p_msg_data                 => l_msg_data,
	  p_data_extract_id          => p_data_extract_id,
	  p_extract_method           => p_extract_method,
	  p_process                  => 'Copy Elements'
	);

	if l_return_status = FND_API.G_RET_STS_ERROR then
	  debug('Reentry Failed Copy Elements');
	  raise FND_API.G_EXC_ERROR;
	elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
	  debug('Reentry Failed Copy Elements');
	  raise FND_API.G_EXC_UNEXPECTED_ERROR ;
	end if;

  end if; -- check for status

  -- End of API body.

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to Copy_Elements_Pvt;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Copy_Elements_Pvt;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to Copy_Elements_Pvt;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Copy_Elements;

PROCEDURE Copy_Default_Rules
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_extract_method      IN      VARCHAR2,
  p_src_data_extract_id IN      NUMBER,
  p_data_extract_id     IN      NUMBER
) AS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Copy_Default_Rules';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_last_update_date    date;
  l_last_updated_by     number;
  l_last_update_login   number;
  l_creation_date       date;
  l_created_by          number;
  l_default_rule_id     number;
  l_account_distribution_id number;
  l_alloc_rule_percent_id   number;
  l_default_assignment_id   number;
  l_rowid1              varchar2(100);
  l_rowid2              varchar2(100);
  l_rowid3              varchar2(100);

  /* Start bug no 1308558 */
  -- These rowid's are needed for
  -- PSB_ENTITY_SET AND PSB_ENTITY_ASSIGNMENT
  l_rowid4		VARCHAR2(1000);
  l_rowid5		VARCHAR2(1000);
  /* End bug no 1308558 */

  l_status              varchar2(1);
  l_insert_flag         varchar2(1);
  l_return_status       varchar2(1);
  l_msg_count           number;
  l_default_count           number;
  l_src_default_rule_id     number;
  l_src_pay_element_id      number;
  l_src_pay_option_id       number;
  l_src_attribute_value_id  number;
  l_dest_pay_element_id     number;
  l_dest_pay_option_id      number;
  l_dest_attribute_value_id number;
  l_src_pay_element_name    varchar2(30);
  l_src_pay_option_name     psb_pay_element_options.name%type; -- bug 5149134
  l_src_grade_step          number;
  --UTF8 changes for Bug No : 2615261
  l_src_attribute_value     psb_attribute_values.attribute_value%TYPE;
  l_src_entity_id           number;
  l_entity_id               number;
  l_set_relation_id         number;
  l_set_name                varchar2(100);
  l_msg_data                varchar2(1000);
  l_restart_id              number;

  /* Start bug no 1308558 */
  -- local variables needed for
  -- PSB_ENTITY_SET AND PSB_ENTITY_ASSIGNMENT
  l_ext_default_rule_id		NUMBER;
  l_entity_set_id		NUMBER;
  l_new_entity_set_id		NUMBER;
  l_business_group_id		NUMBER;
  l_set_of_books_id		NUMBER;
  l_entity_set_name             VARCHAR2(30);
  l_message_name        VARCHAR2(2000); -- bug 5149134
  l_exec_from_position  VARCHAR2(1);  --bug 4273111

  TYPE default_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_default_tbl default_tbl_type;
  /* End bug no 1308558 */





  Cursor C_Defaults is
    Select default_rule_id,
           name,
	   global_default_flag,
	   business_group_id,
	   entity_id,
           priority,
           overwrite  -- bug 4179734
      from psb_defaults
     where data_extract_id = p_src_data_extract_id;

  Cursor C_Position_Sets is
    Select aps.name,
	   effective_start_date,
	   effective_end_date
      from psb_set_relations rels, psb_account_position_sets aps
    where  rels.account_position_set_id = aps.account_position_set_id
      and  aps.data_extract_id  = p_src_data_extract_id
      and  rels.default_rule_id = l_src_default_rule_id;

  Cursor C_Def_Distr is
    Select account_distribution_id,
	   chart_of_accounts_id,
	   code_combination_id,
	   distribution_percent
      from psb_default_account_distrs
     where default_rule_id = l_src_default_rule_id;

  Cursor C_Def_Assign is
    Select assignment_type,attribute_id,
	   attribute_value_id,attribute_value,
	   pay_element_id,pay_element_option_id,
	   element_value,element_value_type,
	   currency_code,pay_basis
      from psb_default_assignments
     where default_rule_id = l_src_default_rule_id;

  Cursor C_Pay_Element is
    Select name
      from psb_pay_elements
     where data_extract_id = p_src_data_extract_id
       and pay_element_id  = l_src_pay_element_id;

  Cursor C_Pay_Element_Dest is
    Select pay_element_id
      from psb_pay_elements
     where data_extract_id = p_data_extract_id
       and name = l_src_pay_element_name;
  -- Following two cursor modified as part of bug #5407267
  -- Bug 4179764 .In the following cursor added
  -- the grade_step in the select clause
  CURSOR C_Pay_Option IS
    SELECT name, nvl(grade_step, -1) grade_step
      FROM psb_pay_element_options
     WHERE pay_element_id        = l_src_pay_element_id
       AND pay_element_option_id = l_src_pay_option_id;

  CURSOR C_Pay_Option_Dest IS
    SELECT pay_element_option_id
      FROM psb_pay_element_options peo, psb_pay_elements pe
     WHERE peo.pay_element_id = pe.pay_element_id
       AND peo.pay_element_id = l_dest_pay_element_id
       AND peo.name           = l_src_pay_option_name
       AND DECODE(pe.hr_element_type_id, null, -1, DECODE(pe.salary_type,
           'STEP', peo.grade_step, -1)) = l_src_grade_step;

  Cursor C_Attr_Val is
    Select attribute_value
      from psb_attribute_values
     where data_extract_id = p_src_data_extract_id
       and attribute_value_id  = l_src_attribute_value_id;

  Cursor C_Attr_Val_Dest is
    Select attribute_value_id
      from psb_attribute_values
     where data_extract_id = p_data_extract_id
       and attribute_value  = l_src_attribute_value;

  Cursor C_Alloc is
    Select allocation_rule_id,
	   period_num,
	   monthly,
	   quarterly,
	   semi_annual
      from psb_allocrule_percents_v
     where allocation_rule_id = l_src_entity_id;

  Cursor C_Account_Sets is
    Select account_position_set_id
      from psb_account_position_sets
     where name = l_set_name
       and data_extract_id = p_data_extract_id;

  /* Start bug no 1308558 */
  -- This cursor selects all the existing
  -- entity sets associated with source data extract
  CURSOR l_entity_set_csr
  IS
  SELECT *
  FROM   psb_entity_set
  WHERE  data_extract_id  = p_src_data_extract_id
  AND    entity_type = 'DEFAULT_RULE';


  -- This cursor selects all the entity
  -- assignments associated with the data
  -- extract
  CURSOR l_entity_assignment_csr
  IS
  SELECT *
  FROM   psb_entity_assignment
  WHERE  entity_set_id = l_entity_set_id;
  /* End bug no 1308558 */

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT Copy_Default_Rules_Pvt;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inside Copy rule program');

  -- API body
  l_last_update_date  := sysdate;
  l_last_updated_by   := FND_GLOBAL.USER_ID;
  l_last_update_login := FND_GLOBAL.LOGIN_ID;
  l_creation_date     := sysdate;
  l_created_by        := FND_GLOBAL.USER_ID;

  PSB_HR_EXTRACT_DATA_PVT.Check_Reentry
  (p_api_version              => 1.0  ,
   p_return_status            => l_return_status,
   p_msg_count                => l_msg_count,
   p_msg_data                 => l_msg_data,
   p_data_extract_id          => p_data_extract_id,
   p_process                  => 'Copy Default Rules',
   p_status                   => l_status,
   p_restart_id               => l_restart_id
   );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  end if;

  if (l_status <> 'C') then

     /* Start bug no 1308558 */
     l_default_tbl.DELETE;
     /* End bug no 1308558 */

     For C_Defaults_Rec in C_Defaults
     Loop
	l_src_default_rule_id := C_Defaults_Rec.default_rule_id;
	l_src_entity_id := C_Defaults_Rec.entity_id;

	Select count(*) into l_default_count
	  from psb_defaults
	 where name = C_Defaults_Rec.name
	   and data_extract_id = p_data_extract_id;

       If (l_default_count = 0) then
	   SELECT psb_entity_s.nextval
	     INTO l_entity_id
	   FROM dual;

	INSERT INTO psb_entity
		    (entity_id,
		     entity_type,
		     entity_subtype,
		     name,
		     last_update_date,
		     last_updated_by,
		     last_update_login,
		     created_by,
		     creation_date)
	       VALUES( l_entity_id,
		       'ALLOCRULE',
		       'POSITION',
		       l_entity_id,
		       l_last_update_date,
		       l_last_updated_by,
		       l_last_update_login,
		       l_created_by,
		       l_creation_date);

	Select psb_defaults_s.nextval
	  into l_default_rule_id
	  from dual;

	PSB_DEFAULTS_PVT.Insert_Row(
	p_api_version                   => 1.0,
	p_init_msg_list                 => FND_API.G_FALSE,
	p_commit                        => FND_API.G_FALSE,
	p_validation_level              => FND_API.G_VALID_LEVEL_FULL,
	p_return_status                 => l_return_status,
	p_msg_count                     => l_msg_count,
	p_msg_data                      => l_msg_data,
	--
	p_row_id                        => l_rowid1,
	p_default_rule_id               => l_default_rule_id,
	p_name                          => C_Defaults_Rec.name,
	p_global_default_flag           => C_Defaults_Rec.global_default_flag,
	p_data_extract_id               => p_data_extract_id,
	p_business_group_id             => C_Defaults_Rec.business_group_id,
	p_entity_id                     => l_entity_id,
	p_priority                      => C_Defaults_Rec.priority,
	p_creation_date                 => l_creation_date,
	p_created_by                    => l_created_by,
	p_last_update_date              => l_last_update_date,
	p_last_updated_by               => l_last_updated_by,
	p_last_update_login             => l_last_update_login,

        /* Bug 4179734 Start */
        p_overwrite                     => c_defaults_rec.overwrite
        /* Bug 4179734 End*/
	);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	   raise FND_API.G_EXC_ERROR;
	end if;

	/* Start bug no 1308558 */
        -- This tables will store all existing default rule ID's
	l_default_tbl(c_defaults_rec.default_rule_id):= l_default_rule_id;
	/* End bug no 1308558 */


	For C_Position_Sets_Rec in C_Position_Sets
	Loop
	  l_set_name := C_Position_Sets_Rec.name;
	  For C_Account_Sets_Rec in C_Account_Sets
	  Loop
	    l_set_relation_id := null;
	    PSB_Set_Relation_PVT.Insert_Row
	    ( p_api_version              => 1.0,
	      p_init_msg_list            => FND_API.G_FALSE,
	      p_commit                   => FND_API.G_FALSE,
	      p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
	      p_return_status            => l_return_status,
	      p_msg_count                => l_msg_count,
	      p_msg_data                 => l_msg_data,
	      p_Row_Id                   => l_rowid2,
	      p_Set_Relation_Id          => l_set_relation_id,
	      p_Account_Position_Set_Id  => C_Account_Sets_Rec.account_position_set_id,
	      p_Allocation_Rule_Id      => null,
	      p_Budget_Group_Id         => null,
	      p_Budget_Workflow_Rule_Id => null,
	      p_Constraint_Id           => null,
	      p_Default_Rule_Id         => l_default_rule_id,
	      p_Parameter_Id            => null,
	      p_Position_Set_Group_Id   => null,
/* Budget Revision Rules Enhancement Start */
	      p_rule_id                 => null,
	      p_apply_balance_flag      => null,
/* Budget Revision Rules Enhancement End */
	      p_Effective_Start_Date    => C_Position_Sets_Rec.effective_start_date,
	      p_Effective_End_Date      => C_Position_Sets_Rec.effective_end_date,
	      p_last_update_date        => l_last_update_date,
	      p_last_updated_by         => l_last_updated_by,
	      p_last_update_login       => l_last_update_login,
	      p_created_by              => l_created_by,
	      p_creation_date           => l_creation_date
	   );

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	     raise FND_API.G_EXC_ERROR;
	  end if;

	  End Loop;

	End Loop;

	For C_Def_Assign_Rec in C_Def_Assign
	Loop
	  l_insert_flag := 'Y';
	  select psb_default_assignments_s.nextval
	    into l_default_assignment_id
	  from dual;
	  l_src_pay_element_id := C_Def_Assign_Rec.pay_element_id;
	  l_src_pay_option_id  := C_Def_Assign_Rec.pay_element_option_id;
	  l_src_attribute_value_id := C_Def_Assign_Rec.attribute_value_id;
	  l_src_pay_element_name := null;
	  l_src_pay_option_name := null;
          l_src_grade_step      := NULL;
          /* Start Bug #4179714 */
          l_src_attribute_value := null;
          /* End Bug #4179714 */
	  l_dest_pay_element_id := null;
	  l_dest_pay_option_id := null;
	  l_dest_attribute_value_id := null;

	  For C_Pay_Element_Rec in C_Pay_Element
	  Loop
	    l_src_pay_element_name := C_Pay_Element_Rec.name;
	  End Loop;

	  For C_Pay_Option_Rec in C_Pay_Option
	  Loop
	    l_src_pay_option_name := C_Pay_Option_Rec.name;
            /* Bug 4179764 Start */
            l_src_grade_step      := C_Pay_Option_Rec.grade_step;
            /* Bug 4179764 End */
	  End Loop;

	  For C_Pay_Element_Dest_Rec in C_Pay_Element_Dest
	  Loop
	    l_dest_pay_element_id := C_Pay_Element_Dest_Rec.pay_element_id;
	    For C_Pay_Option_Dest_Rec in C_Pay_Option_Dest
	    Loop
	    l_dest_pay_option_id := C_Pay_Option_Dest_Rec.pay_element_option_id;
	    End Loop;
	  End Loop;

	  For C_Attr_Val_Rec in C_Attr_Val
	  Loop
	    l_src_attribute_value := C_Attr_Val_Rec.attribute_value;
	  End Loop;

	  For C_Attr_Val_Dest_Rec in C_Attr_Val_Dest
	  Loop
	    l_dest_attribute_value_id := C_Attr_Val_Dest_Rec.attribute_value_id;
	  End Loop;

	  if ((C_Def_Assign_Rec.assignment_type = 'ELEMENT') and
	      (l_dest_pay_element_id is null)) then
	      l_insert_flag := 'N';
	  end if;

	  if (l_insert_flag = 'Y') then
	  PSB_DEFAULT_ASSIGNMENTS_PVT.Insert_Row
	    ( p_api_version              => 1.0,
	      p_init_msg_list            => FND_API.G_FALSE,
	      p_commit                   => FND_API.G_FALSE,
	      p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
	      p_return_status            => l_return_status,
	      p_msg_count                => l_msg_count,
	      p_msg_data                 => l_msg_data,
	      p_Row_Id                   => l_rowid3,
	      p_default_assignment_id    => l_default_assignment_id,
	      p_default_rule_id          => l_default_rule_id,
	      p_assignment_type          => C_Def_Assign_Rec.assignment_type,
	      p_attribute_id             => C_Def_Assign_Rec.attribute_id,
	      p_attribute_value_id       => l_dest_attribute_value_id,
	      p_attribute_value          => C_Def_Assign_Rec.attribute_value,
	      p_pay_element_id           => l_dest_pay_element_id,
	      p_pay_basis                => C_Def_Assign_Rec.pay_basis,
	      p_element_value_type       => C_Def_Assign_Rec.element_value_type,
	      p_pay_element_option_id    => l_dest_pay_option_id,
	      p_element_value            => C_Def_Assign_Rec.element_value,
	      p_currency_code            => C_Def_Assign_Rec.currency_code,
	      p_creation_date            => l_creation_date,
	      p_created_by               => l_created_by,
	      p_last_update_date         => l_last_update_date,
	      p_last_updated_by          => l_last_updated_by,
	      p_last_update_login        => l_last_update_login
	   );

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	     raise FND_API.G_EXC_ERROR;
	  end if;
	 end if;

	End Loop;

	For C_Def_Distr_Rec in C_Def_Distr
	Loop
	  select psb_default_account_distrs_s.nextval
	    into l_account_distribution_id
	  from dual;

	  Insert into Psb_default_account_distrs
	  (account_distribution_id,
	   default_rule_id,
	   chart_of_accounts_id,
	   code_combination_id,
	   distribution_percent,
	   last_update_date    ,
	   last_updated_by     ,
	   last_update_login   ,
	   created_by          ,
	   creation_date       )
	   VALUES
	   (
	    l_account_distribution_id,
	    l_default_rule_id,
	    C_Def_Distr_Rec.chart_of_accounts_id,
	    C_Def_Distr_Rec.code_combination_id,
	    C_Def_Distr_Rec.distribution_percent,
	    l_last_update_date,
	    l_last_updated_by ,
	    l_last_update_login ,
	    l_created_by,
	    l_creation_date);
	end Loop;

	For C_Alloc_Rec in C_Alloc
	Loop
	   PSB_ALLOCRULE_PERCENTS_PVT.Insert_Row
	    ( p_api_version              => 1.0,
	      p_init_msg_list            => FND_API.G_FALSE,
	      p_commit                   => FND_API.G_FALSE,
	      p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
	      p_return_status            => l_return_status,
	      p_msg_count                => l_msg_count,
	      p_msg_data                 => l_msg_data,
	      p_allocation_rule_percent_id  => l_alloc_rule_percent_id,
	      p_allocation_rule_id       => l_entity_id,
	      p_period_num               => C_Alloc_Rec.period_num,
	      p_monthly                  => C_Alloc_Rec.monthly,
	      p_quarterly                => C_Alloc_Rec.quarterly ,
	      p_semi_annual              => C_Alloc_Rec.semi_annual,
	      p_attribute1               => null,
	      p_attribute2               => null,
	      p_attribute3               => null,
	      p_attribute4               => null,
	      p_attribute5               => null,
	      p_context                  => null,
	      p_last_update_date        => l_last_update_date,
	      p_last_updated_by         => l_last_updated_by,
	      p_last_update_login       => l_last_update_login,
	      p_created_by              => l_created_by,
	      p_creation_date           => l_creation_date);
	end Loop;

      end if;
    End Loop;

    /* Start bug no 1308558 */
    -- The following loop gets all the old entity set
    -- data and copies the data for the new data
    -- extract set id.


    FOR l_entity_set_rec IN l_entity_set_csr
    LOOP
      -- get the old eneity set id for the inner loop to execute
      l_entity_set_id := l_entity_set_rec.entity_set_id;

      -- bug 4273111.
      l_exec_from_position := l_entity_set_rec.executable_from_position;

      -- generate the sequence for new entity sets
      FOR l_new_entity_rec IN (SELECT PSB_ENTITY_SET_S.NEXTVAL entity_set_id
	  		       FROM  dual)
      LOOP
	l_new_entity_set_id := l_new_entity_rec.entity_set_id;
      END LOOP;


      -- get the set of books, business group for the target data extract
      FOR l_data_extract_rec IN (SELECT business_group_id,
         				set_of_books_id
	  			 FROM 	psb_data_extracts
	  			 WHERE  data_extract_id = p_data_extract_id)
      LOOP
  	l_business_group_id := l_data_extract_rec.business_group_id;
  	l_set_of_books_id   := l_data_extract_rec.set_of_books_id;
      END LOOP;

      /*IF LENGTH(l_entity_set_rec.name) > 23 THEN
        l_entity_set_name := SUBSTR(l_entity_set_rec.name, 1, 23);
      ELSE
        l_entity_set_name := l_entity_set_rec.name;
      END IF;*/

      FND_MESSAGE.set_name('PSB', 'PSB_COPY_RULE_SET_NAME');
      FND_MESSAGE.set_token('RULE_SET_NAME', l_entity_set_rec.name);
      l_message_name := FND_MESSAGE.get||'-'||p_data_extract_id;

      l_return_status := null;
      -- call the insert procedure PSB_ENTITY_SET.INSERT_ROW
      PSB_ENTITY_SET_PVT.Insert_Row
     (p_api_version          => 1.0,
      p_init_msg_list        => FND_API.G_FALSE,
      p_commit               => FND_API.G_FALSE,
      p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
      p_return_status        => l_return_status,
      p_msg_count            => l_msg_count,
      p_msg_data             => l_msg_data,
      P_ROWID		     => l_rowid4,
      P_ENTITY_SET_ID	     => l_new_entity_set_id,
      P_ENTITY_TYPE	     => 'DEFAULT_RULE',
      P_NAME                 => l_message_name,
      P_DESCRIPTION	     => l_entity_set_rec.description,
      P_BUDGET_GROUP_ID	     => l_business_group_id,
      P_SET_OF_BOOKS_ID	     => l_set_of_books_id,
      P_DATA_EXTRACT_ID	     => p_data_extract_id,
      P_CONSTRAINT_THRESHOLD => null,
      P_ENABLE_FLAG	     => null,
      -- bug 4273111. set the following in parameter
      P_EXECUTABLE_FROM_POSITION => NVL(l_exec_from_position,'N'),
      P_ATTRIBUTE1	     => null,
      P_ATTRIBUTE2	     => null,
      P_ATTRIBUTE3	     => null,
      P_ATTRIBUTE4	     => null,
      P_ATTRIBUTE5	     => null,
      P_ATTRIBUTE6	     => null,
      P_ATTRIBUTE7	     => null,
      P_ATTRIBUTE8	     => null,
      P_ATTRIBUTE9           => null,
      P_ATTRIBUTE10	     => null,
      P_CONTEXT		     => null,
      p_Last_Update_Date     => l_last_update_date,
      p_Last_Updated_By	     => l_last_updated_by,
      p_Last_Update_Login    => l_last_update_login,
      p_Created_By	     => l_created_by,
      p_Creation_Date	     => l_creation_date);

      -- check the success of the API

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      FOR l_entity_assignment_rec IN l_entity_assignment_csr
      LOOP

        -- insert the data into entity assignment table
	PSB_ENTITY_ASSIGNMENT_PVT.Insert_Row (
       	  p_api_version	         => 1.0,
	  p_init_msg_list	 => FND_API.G_FALSE,
          p_commit		 => FND_API.G_FALSE,
	  p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	  p_return_status	 => l_return_status,
	  p_msg_count		 => l_msg_count,
	  p_msg_data		 => l_msg_data,
	  P_ROWID		 => l_rowid5,
	  P_ENTITY_SET_ID	 => l_new_entity_set_id,
	  P_ENTITY_ID
            => l_default_tbl(l_entity_assignment_rec.entity_id),
	  P_PRIORITY		 => l_entity_assignment_rec.priority,
	  P_SEVERITY_LEVEL	 => l_entity_assignment_rec.severity_level,
	  P_EFFECTIVE_START_DATE
            => l_entity_assignment_rec.effective_start_date,
	  P_EFFECTIVE_END_DATE	 => l_entity_assignment_rec.effective_end_date,
	  p_Last_Update_Date	 => l_last_update_date,
	  p_Last_Updated_By	 => l_last_updated_by,
	  p_Last_Update_Login	 => l_last_update_login,
	  p_Created_By	         => l_created_by,
	  p_Creation_Date	 => l_creation_date);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

    END LOOP;

    END LOOP;
    /* End bug no 1308558 */

  PSB_HR_EXTRACT_DATA_PVT.Reentrant_Process
  ( p_api_version              => 1.0  ,
    p_return_status            => l_return_status,
    p_msg_count                => l_msg_count,
    p_msg_data                 => l_msg_data,
    p_data_extract_id          => p_data_extract_id,
    p_extract_method           => p_extract_method,
    p_process                  => 'Copy Default Rules'
  );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     debug('Reentry Failed Copy Default Rules');
     raise FND_API.G_EXC_ERROR;
  end if;
  end if;

  -- End of API body.

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     fnd_file.put_line(fnd_file.log, sqlerrm||' - exception ');
     debug('SQLCODE '||SQLCODE);
     rollback to Copy_Default_Rules_Pvt;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     fnd_file.put_line(fnd_file.log, sqlerrm||' - exception ');
     debug('SQLCODE '||SQLCODE);
     rollback to Copy_Default_Rules_Pvt;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     fnd_file.put_line(fnd_file.log, sqlerrm||' - exception ');
     debug('SQLCODE '||SQLCODE);
     rollback to Copy_Default_Rules_Pvt;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Copy_Default_Rules;

/* ----------------------------------------------------------------------- */

  -- Get Debug Information

  -- This Module is used to retrieve Debug Information for this routine. It
  -- prints Debug Information when run as a Batch Process from SQL*Plus. For
  -- the Debug Information to be printed on the Screen, the SQL*Plus parameter
  -- 'Serveroutput' should be set to 'ON'

  FUNCTION get_debug RETURN VARCHAR2 AS

  BEGIN

    return(g_dbug);

  END get_debug;

/* ----------------------------------------------------------------------- */

END PSB_COPY_DATA_EXTRACT_PVT;

/
