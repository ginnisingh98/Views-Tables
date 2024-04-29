--------------------------------------------------------
--  DDL for Package Body PV_USER_REGISTRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_USER_REGISTRATION_PKG" as
/* $Header: pvregisb.pls 115.4 2002/12/11 10:24:26 anubhavk ship $ */

G_PKG_NAME CONSTANT VARCHAR2(100) := 'pv_user_registration_pkg';
g_item_type         varchar2(100) := 'PVLEADAS';


procedure notify_user_by_email(
                     p_creator            IN  VARCHAR2,
                     p_username           IN  VARCHAR2,
                     p_password           IN  VARCHAR2,
						   x_item_type          OUT NOCOPY VARCHAR2,
						   x_item_key           OUT NOCOPY VARCHAR2,
						   x_return_status      OUT NOCOPY VARCHAR2,
						   x_msg_count          OUT NOCOPY NUMBER,
						   x_msg_data           OUT NOCOPY VARCHAR2) is

	l_message           VARCHAR2(2000);
	l_api_name          CONSTANT VARCHAR2(30) := 'notify_user_by_email';

   l_wf_item_type            VARCHAR2(30) := 'PVREGIS';
	l_wf_notify_process       VARCHAR2(30) := 'USER_REGISTRATION_NOTIFY_PR';
	l_wf_creator_attr_name    VARCHAR2(30) := 'USER_RGSTRTN_CREATOR';
	l_wf_username_attr_name   VARCHAR2(30) := 'USER_RGSTRTN_USER';
	l_wf_password_attr_name   VARCHAR2(30) := 'USER_RGSTRTN_USER_PASSWORD';

	l_wf_item_key          number;

begin

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	select pv_lead_workflows_s.nextval into l_wf_item_key
	from   sys.dual;

	wf_engine.CreateProcess( ItemType => l_wf_item_type,
                            ItemKey  => l_wf_item_key,
                            process  => l_wf_notify_process);

	wf_engine.SetItemUserKey (itemType => l_wf_item_type,
                             itemKey  => l_wf_item_key,
                             userKey  => l_wf_item_key);

	wf_engine.setItemOwner( ITEMTYPE => l_wf_item_type,
									ITEMKEY  => l_wf_item_key,
									OWNER    => p_creator);

	wf_engine.SetItemAttrText  (itemtype => l_wf_item_type,
                               itemkey  => l_wf_item_key,
                               aname    => l_wf_creator_attr_name,
                               avalue   => p_creator);

	wf_engine.SetItemAttrText  (itemtype => l_wf_item_type,
                               itemkey  => l_wf_item_key,
                               aname    => l_wf_username_attr_name,
                               avalue   => p_username);

	wf_engine.SetItemAttrText  (itemtype => l_wf_item_type,
                               itemkey  => l_wf_item_key,
                               aname    => l_wf_password_attr_name,
                               avalue   => p_password);

	wf_engine.StartProcess( itemtype => l_wf_item_type,
                           itemkey  => l_wf_item_key);

	x_item_type := l_wf_item_type;
	x_item_key := l_wf_item_key;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

	  fnd_msg_pub.Count_And_Get( p_encoded  => FND_API.G_FALSE
                                ,p_count   => x_msg_count
										  ,p_data    => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		fnd_msg_pub.Count_And_Get( p_encoded  => FND_API.G_FALSE
                                ,p_count   => x_msg_count
										  ,p_data    => x_msg_data);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  fnd_msg_pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);

		fnd_msg_pub.Count_And_Get( p_encoded  => FND_API.G_FALSE
                                ,p_count   => x_msg_count
										  ,p_data    => x_msg_data);

end notify_user_by_email;


end pv_user_registration_pkg;

/
