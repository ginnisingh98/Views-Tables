--------------------------------------------------------
--  DDL for Package Body ASG_CUSTOM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_CUSTOM_PUB" as
/* $Header: asgpcstb.pls 120.1 2005/08/12 02:49:55 saradhak noship $ */

  PROCEDURE customize_pub_item(
   p_api_version_number         IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 :=FND_API.G_FALSE,
   p_pub_item_name              IN VARCHAR2,
   p_base_table_name            IN VARCHAR2,
   p_primary_key_columns        IN VARCHAR2,
   p_data_columns               IN VARCHAR2,
   p_additional_filter          IN VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_error_message              OUT NOCOPY VARCHAR2
                              )
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Customize_pub_item';
l_api_version_number    CONSTANT NUMBER       := 1.0;
l_return_status		 VARCHAR2(10);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT customize_pub_item_PUB;

   -- Standard call to check for call compatibility.
   if NOT FND_API.Compatible_API_Call
   (
        l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME
   )
   then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   if FND_API.to_Boolean( p_init_msg_list)
   then
      fND_MSG_PUB.initialize;
   end if;

   -- Check the input parameters
   -- p_pub_item_name, p_base_table_name, p_primary_key_columns
   --   should not be NULL
   if ( p_pub_item_name is NULL OR
        p_base_table_name is NULL OR
        p_primary_key_columns is NULL )
   then
        raise FND_API.G_EXC_ERROR;
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   asg_custom_pvt.customize_pub_item (
       p_api_version_number   => p_api_version_number,
       p_init_msg_list        => p_init_msg_list,
       p_pub_item_name        => upper(p_pub_item_name),
       p_base_table_name      => upper(p_base_table_name),
       p_primary_key_columns  => upper(p_primary_key_columns),
       p_data_columns         => upper(p_data_columns),
       p_additional_filter    => upper(p_additional_filter),
       x_msg_count            => x_msg_count,
       x_return_status        => l_return_status,
       x_error_message        => x_error_message);

   -- Both G_EXC_ERROR and G_EXC_UNEXPECTED_ERROR are handled in
   -- the API exception handler.

   if l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   then

   -- Unexpected error, abort processing.

      raise FND_API.G_EXC_UNEXPECTED_ERROR;

   elsif l_return_status = FND_API.G_RET_STS_ERROR THEN

   -- Error, abort processing

      raise FND_API.G_EXC_ERROR;

   end if;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
      Rollback to customize_pub_item_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      (
         p_count                => x_msg_count,
         p_data                 => x_error_message
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      Rollback to customize_pub_item_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      (
         p_count                => x_msg_count,
         p_data                 => x_error_message
      );
  WHEN OTHERS THEN
      Rollback to customize_pub_item_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      if FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      then
         FND_MSG_PUB.Add_Exc_Msg
         (
            G_PKG_NAME,
            l_api_name,
            sqlerrm
         );
      end if;
      FND_MSG_PUB.Count_And_Get
      (
         p_count                => x_msg_count,
         p_data                 => x_error_message
      );


 END  customize_pub_item ;


  PROCEDURE mark_dirty (
   p_api_version_number         IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 :=FND_API.G_FALSE,
   p_pub_item                   IN VARCHAR2,
   p_accessList                 IN asg_download.access_list,
   p_userid_list                IN asg_download.user_list,
   p_dmlList                    IN asg_download.dml_list,
   p_timestamp                  IN DATE,
   x_return_status              OUT NOCOPY VARCHAR2
                        )
 IS

  l_api_version_number    CONSTANT NUMBER       := 1.0;
  l_api_name              CONSTANT VARCHAR2(30) := 'MARK_DIRTY1' ;
  l_return_status		 VARCHAR2(10);

  BEGIN
      -- Standard Start of API savepoint
   SAVEPOINT mark_dirty1;

   -- Standard call to check for call compatibility.
   if NOT FND_API.Compatible_API_Call
   (
        l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME
   )
   then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   if FND_API.to_Boolean( p_init_msg_list)
   then
      FND_MSG_PUB.initialize;
   end if;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   asg_custom_pvt.mark_dirty(
               p_api_version_number   => p_api_version_number,
               p_init_msg_list        => p_init_msg_list,
               p_pub_item      => upper(p_pub_item),
               p_accessList    => p_accessList,
               p_userid_list   => p_userid_list,
               p_dmlList       => p_dmlList,
               p_timestamp     => p_timestamp,
               x_return_status => l_return_status);

     -- Both G_EXC_ERROR and G_EXC_UNEXPECTED_ERROR are handled in
   -- the API exception handler.

   if l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   then

   -- Unexpected error, abort processing.

      raise FND_API.G_EXC_UNEXPECTED_ERROR;

   elsif l_return_status = FND_API.G_RET_STS_ERROR THEN

   -- Error, abort processing

      raise FND_API.G_EXC_ERROR;

   end if;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
      Rollback to mark_dirty1;
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      Rollback to mark_dirty1;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
      Rollback to mark_dirty1;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END ;


  PROCEDURE mark_dirty (
   p_api_version_number         IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 :=FND_API.G_FALSE,
   p_pub_item                   IN VARCHAR2,
   p_accessList                 IN asg_download.access_list,
   p_userid_list                IN asg_download.user_list,
   p_dml_type                   IN CHAR,
   p_timestamp                  IN DATE,
   x_return_status              OUT NOCOPY VARCHAR2
	   	     ) IS

  l_api_version_number    CONSTANT NUMBER       := 1.0;
  l_api_name              CONSTANT VARCHAR2(30) := 'MARK_DIRTY2' ;
  l_return_status		 VARCHAR2(10);

  BEGIN
      -- Standard Start of API savepoint
   SAVEPOINT mark_dirty2;

   -- Standard call to check for call compatibility.
   if NOT FND_API.Compatible_API_Call
   (
        l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME
   )
   then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   if FND_API.to_Boolean( p_init_msg_list)
   then
      FND_MSG_PUB.initialize;
   end if;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   asg_custom_pvt.mark_dirty(
                           p_api_version_number   => p_api_version_number,
                           p_init_msg_list        => p_init_msg_list,
                           p_pub_item      => upper(p_pub_item),
                           p_accessList    => p_accessList,
                           p_userid_list   => p_userid_list,
                           p_dml_type      => p_dml_type,
                           p_timestamp     => p_timestamp,
                           x_return_status => l_return_status);

   -- Both G_EXC_ERROR and G_EXC_UNEXPECTED_ERROR are handled in
   -- the API exception handler.

   if l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   then

   -- Unexpected error, abort processing.

      raise FND_API.G_EXC_UNEXPECTED_ERROR;

   elsif l_return_status = FND_API.G_RET_STS_ERROR THEN

   -- Error, abort processing

      raise FND_API.G_EXC_ERROR;

   end if;


EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
      Rollback to mark_dirty2;
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      Rollback to mark_dirty2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
      Rollback to mark_dirty2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END ;


  PROCEDURE mark_dirty (
   p_api_version_number         IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 :=FND_API.G_FALSE,
   p_pub_item                   IN VARCHAR2,
   p_accessid                   IN NUMBER,
   p_userid                     IN NUMBER,
   p_dml                        IN CHAR,
   p_timestamp                  IN DATE,
   x_return_status              OUT NOCOPY VARCHAR2
		     ) IS
  l_api_version_number    CONSTANT NUMBER       := 1.0;
  l_api_name              CONSTANT VARCHAR2(30) := 'MARK_DIRTY3';
  l_return_status		 VARCHAR2(10);

  BEGIN
      -- Standard Start of API savepoint
   SAVEPOINT mark_dirty3;

   -- Standard call to check for call compatibility.
   if NOT FND_API.Compatible_API_Call
   (
        l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME
   )
   then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   if FND_API.to_Boolean( p_init_msg_list)
   then
      FND_MSG_PUB.initialize;
   end if;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   asg_custom_pvt.mark_dirty(
               p_api_version_number   => p_api_version_number,
               p_init_msg_list        => p_init_msg_list,
	       p_pub_item   => upper(p_pub_item),
               p_accessid   => p_accessid,
               p_userid     => p_userid,
               p_dml        => p_dml,
               p_timestamp  => p_timestamp,
               x_return_status => l_return_status);

     -- Both G_EXC_ERROR and G_EXC_UNEXPECTED_ERROR are handled in
   -- the API exception handler.

   if l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   then

   -- Unexpected error, abort processing.

      raise FND_API.G_EXC_UNEXPECTED_ERROR;

   elsif l_return_status = FND_API.G_RET_STS_ERROR THEN

   -- Error, abort processing

      raise FND_API.G_EXC_ERROR;

   end if;


EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
      Rollback to mark_dirty3;
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      Rollback to mark_dirty3;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
      Rollback to mark_dirty3;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END ;

  PROCEDURE mark_dirty (
            p_api_version_number         IN      NUMBER,
            p_init_msg_list              IN      VARCHAR2 :=FND_API.G_FALSE,
            p_pub_item                   IN VARCHAR2,
            p_accessid                   IN NUMBER,
            p_userid                     IN NUMBER,
            p_dml                        IN CHAR,
            p_timestamp                  IN DATE,
            p_pkvalues                   IN asg_download.pk_list,
            x_return_status              OUT NOCOPY VARCHAR2
		     )
  IS
  l_api_version_number    CONSTANT NUMBER       := 1.0;
  l_api_name              CONSTANT VARCHAR2(30) := 'MARK_DIRTY4';
  l_return_status		 VARCHAR2(10);

  BEGIN

      -- Standard Start of API savepoint
   SAVEPOINT mark_dirty4;

   -- Standard call to check for call compatibility.
   if NOT FND_API.Compatible_API_Call
   (
        l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME
   )
   then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   if FND_API.to_Boolean( p_init_msg_list)
   then
      FND_MSG_PUB.initialize;
   end if;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   asg_custom_pvt.mark_dirty(
               p_api_version_number   => p_api_version_number,
               p_init_msg_list        => p_init_msg_list,
               p_pub_item   =>  upper(p_pub_item),
               p_accessid   =>  p_accessid,
               p_userid     =>  p_userid,
               p_dml        =>  p_dml,
               p_timestamp  =>  p_timestamp,
               p_pkvalues   =>  p_pkvalues,
               x_return_status => l_return_status);

   -- Both G_EXC_ERROR and G_EXC_UNEXPECTED_ERROR are handled in
   -- the API exception handler.

   if l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   then

   -- Unexpected error, abort processing.

      raise FND_API.G_EXC_UNEXPECTED_ERROR;

   elsif l_return_status = FND_API.G_RET_STS_ERROR THEN

   -- Error, abort processing

      raise FND_API.G_EXC_ERROR;

   end if;


EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
      Rollback to mark_dirty4;
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      Rollback to mark_dirty4;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
      Rollback to mark_dirty4;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END ;


  PROCEDURE mark_dirty (
   p_api_version_number         IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 :=FND_API.G_FALSE,
   p_pub_item                   IN VARCHAR2,
   p_accessList                 IN asg_download.access_list,
   p_userid_list                IN asg_download.user_list,
   p_dml_type                   IN CHAR,
   p_timestamp                  IN DATE,
   p_bulk_flag                  IN BOOLEAN,
   x_return_status              OUT NOCOPY VARCHAR2
		     )
 IS
  l_return_status		 VARCHAR2(10);
  l_api_version_number    CONSTANT NUMBER       := 1.0;
  l_api_name              CONSTANT VARCHAR2(30) := 'MARK_DIRTY5';
  BEGIN
      -- Standard Start of API savepoint
   SAVEPOINT mark_dirty5;

   -- Standard call to check for call compatibility.
   if NOT FND_API.Compatible_API_Call
   (
        l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME
   )
   then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   if FND_API.to_Boolean( p_init_msg_list)
   then
      FND_MSG_PUB.initialize;
   end if;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   asg_custom_pvt.mark_dirty(
                p_api_version_number   => p_api_version_number,
                p_init_msg_list        => p_init_msg_list,
		p_pub_item     => upper(p_pub_item),
                p_accessList   => p_accessList,
                p_userid_list  => p_userid_list,
                p_dml_type     => p_dml_type,
                p_timestamp    => p_timestamp,
                p_bulk_flag    => p_bulk_flag,
                x_return_status => l_return_status);

   -- Both G_EXC_ERROR and G_EXC_UNEXPECTED_ERROR are handled in
   -- the API exception handler.

   if l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   then

   -- Unexpected error, abort processing.

      raise FND_API.G_EXC_UNEXPECTED_ERROR;

   elsif l_return_status = FND_API.G_RET_STS_ERROR THEN

   -- Error, abort processing

      raise FND_API.G_EXC_ERROR;

   end if;


EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
      Rollback to mark_dirty5;
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      Rollback to mark_dirty5;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
      Rollback to mark_dirty5;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END ;




END ASG_CUSTOM_PUB;

/
