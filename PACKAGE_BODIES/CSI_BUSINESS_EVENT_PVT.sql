--------------------------------------------------------
--  DDL for Package Body CSI_BUSINESS_EVENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_BUSINESS_EVENT_PVT" AS
/* $Header: csivbesb.pls 120.2 2007/10/26 21:24:35 fli noship $ */

PROCEDURE create_instance_event
   (p_api_version               IN     NUMBER
    ,p_commit                   IN     VARCHAR2
    ,p_init_msg_list            IN     VARCHAR2
    ,p_validation_level         IN     NUMBER
    ,p_instance_id              IN     NUMBER
    ,p_subject_instance_id      IN     NUMBER
    ,x_return_status            OUT    NOCOPY VARCHAR2
    ,x_msg_count                OUT    NOCOPY NUMBER
    ,x_msg_data                 OUT    NOCOPY VARCHAR2
    ) IS

  l_key          VARCHAR2(240);
  l_event_name   VARCHAR2(240) := 'oracle.apps.csi.instance.create';

BEGIN
  SAVEPOINT  create_item_instance_event;

  csi_gen_utility_pvt.put_line('Inside API CSI_BUSINESS_EVENT_PVT.create_instance_event');

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get item key
  l_key := CSI_HANDLE_EVENT_PKG.item_key(l_event_name);

  csi_gen_utility_pvt.put_line('Event Key: '||l_key);

  -- Raise Event
  CSI_HANDLE_EVENT_PKG.raise_event
       (p_api_version          => p_api_version
        ,p_commit              => p_commit
        ,p_init_msg_list       => p_init_msg_list
        ,p_validation_level    => p_validation_level
        ,p_event_name          => l_event_name
        ,p_event_key           => l_key
        ,p_instance_id         => p_instance_id
        ,p_subject_instance_id => p_subject_instance_id
        ,p_correlation_value   => 'oracle.apps.csi.instance.create');

EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK TO create_item_instance_event;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('CSI','CSI_CREATE_EVENT_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get
        (p_count  => x_msg_count
        ,p_data   => x_msg_data);
      RAISE FND_API.G_EXC_ERROR;
END create_instance_event;

PROCEDURE update_instance_event
   (p_api_version               IN     NUMBER
    ,p_commit                   IN     VARCHAR2
    ,p_init_msg_list            IN     VARCHAR2
    ,p_validation_level         IN     NUMBER
    ,p_instance_id              IN     NUMBER
    ,p_subject_instance_id      IN     NUMBER
    ,x_return_status            OUT    NOCOPY VARCHAR2
    ,x_msg_count                OUT    NOCOPY NUMBER
    ,x_msg_data                 OUT    NOCOPY VARCHAR2
    ) IS

  l_key          VARCHAR2(240);
  l_event_name   VARCHAR2(240) := 'oracle.apps.csi.instance.update';

BEGIN
  SAVEPOINT update_item_instance_event;

  csi_gen_utility_pvt.put_line('Inside API CSI_BUSINESS_EVENT_PVT.update_instance_event');

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get item key
  l_key := CSI_HANDLE_EVENT_PKG.item_key(l_event_name);

  csi_gen_utility_pvt.put_line('Event Key: '||l_key);

  -- Raise Event
  CSI_HANDLE_EVENT_PKG.raise_event
       (p_api_version          => p_api_version
        ,p_commit              => p_commit
        ,p_init_msg_list       => p_init_msg_list
        ,p_validation_level    => p_validation_level
        ,p_event_name          => l_event_name
        ,p_event_key           => l_key
        ,p_instance_id         => p_instance_id
        ,p_subject_instance_id => p_subject_instance_id
        ,p_correlation_value   => 'oracle.apps.csi.instance.update');

EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK TO update_item_instance_event;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('CSI','CSI_UPDATE_EVENT_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get
        (p_count  => x_msg_count
        ,p_data   => x_msg_data);
      RAISE FND_API.G_EXC_ERROR;
END update_instance_event;

END;

/
