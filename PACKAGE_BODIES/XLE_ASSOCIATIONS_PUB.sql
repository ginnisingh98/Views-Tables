--------------------------------------------------------
--  DDL for Package Body XLE_ASSOCIATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLE_ASSOCIATIONS_PUB" AS
/* $Header: xleassmb.pls 120.1 2005/05/03 12:37:13 ttran ship $ */

/* =======================================================================
 | Global Data Types
 * ======================================================================*/

G_PKG_NAME     CONSTANT VARCHAR2(30) :=' XLE_ASSOCIATIONS_PUB';

/*==========================================================================
 |  PROCEDURE
 |    Create_Association
 |
 |  DESCRIPTION
 |    Creates a Legal Association
 |
 |  ARGUMENTS
 |      IN     :
 |               p_init_msg_list
 |               p_commit
 |               p_context
 |               p_subject_type
 |               p_subject_id
 |               p_object_type
 |               p_object_id
 |               p_effective_from
 |               p_assoc_information_context
 |               p_assoc_information1
 |               p_assoc_information2
 |               p_assoc_information3
 |               p_assoc_information4
 |               p_assoc_information5
 |               p_assoc_information6
 |               p_assoc_information7
 |               p_assoc_information8
 |               p_assoc_information9
 |               p_assoc_information10
 |               p_assoc_information11
 |               p_assoc_information12
 |               p_assoc_information13
 |               p_assoc_information14
 |               p_assoc_information15
 |               p_assoc_information16
 |               p_assoc_information17
 |               p_assoc_information18
 |               p_assoc_information19
 |               p_assoc_information20
 |
 |      OUT    :
 |               x_return_status
 |               x_msg_count
 |               x_msg_data
 |               x_association_id
 |
 |      IN/OUT :
 |
 |
 |  MODIFICATION HISTORY
 |
 |    18-MAR-2005   T.Tran          Created.
 |
 |===========================================================================*/


PROCEDURE Create_Association(

  --   *****  Standard API parameters *****
  p_init_msg_list             IN  VARCHAR2 := FND_API.G_TRUE,
  p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
  x_return_status             OUT NOCOPY VARCHAR2,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,


  --   *****  Legal Association information parameters *****
  p_context                   IN  VARCHAR2,
  p_subject_type              IN  VARCHAR2,
  p_subject_id                IN  NUMBER,
  p_object_type               IN  VARCHAR2,
  p_object_id                 IN  NUMBER,
  p_effective_from            IN  DATE,
  p_assoc_information_context IN  VARCHAR2 := NULL,
  p_assoc_information1        IN  VARCHAR2 := NULL,
  p_assoc_information2        IN  VARCHAR2 := NULL,
  p_assoc_information3        IN  VARCHAR2 := NULL,
  p_assoc_information4        IN  VARCHAR2 := NULL,
  p_assoc_information5        IN  VARCHAR2 := NULL,
  p_assoc_information6        IN  VARCHAR2 := NULL,
  p_assoc_information7        IN  VARCHAR2 := NULL,
  p_assoc_information8        IN  VARCHAR2 := NULL,
  p_assoc_information9        IN  VARCHAR2 := NULL,
  p_assoc_information10       IN  VARCHAR2 := NULL,
  p_assoc_information11       IN  VARCHAR2 := NULL,
  p_assoc_information12       IN  VARCHAR2 := NULL,
  p_assoc_information13       IN  VARCHAR2 := NULL,
  p_assoc_information14       IN  VARCHAR2 := NULL,
  p_assoc_information15       IN  VARCHAR2 := NULL,
  p_assoc_information16       IN  VARCHAR2 := NULL,
  p_assoc_information17       IN  VARCHAR2 := NULL,
  p_assoc_information18       IN  VARCHAR2 := NULL,
  p_assoc_information19       IN  VARCHAR2 := NULL,
  p_assoc_information20       IN  VARCHAR2 := NULL,
  x_association_ID            OUT NOCOPY NUMBER)


IS

  l_api_name  CONSTANT  VARCHAR2(20) := 'Create_Association';
  l_association_id      NUMBER;
  l_association_type_id NUMBER;
  l_subject_parent_id   NUMBER;

BEGIN

  x_msg_count	:=	NULL;
  x_msg_data	:=	NULL;

  -- ****   Standard start of API savepoint  ****
  SAVEPOINT Create_Association_SP;


  -- ****  Initialize message list if p_init_msg_list is set to TRUE. ****
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;


  -- ****  Initialize return status to SUCCESS   *****
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  /*-----------------------------------------------+
  |   ========  START OF API BODY  ============   |
  +-----------------------------------------------*/

  --  Validation of the Legal Associations Rules
  --  Returns Association Type ID and Subject Parent ID

  XLE_ASSOC_VALIDATIONS_PVT.Validate_Create_Association (
      p_context,
      p_subject_type,
      p_subject_id,
      p_object_type,
      p_object_id,
      p_effective_from,
      p_assoc_information_context,
      p_assoc_information1,
      p_assoc_information2,
      p_assoc_information3,
      p_assoc_information4,
      p_assoc_information5,
      p_assoc_information6,
      p_assoc_information7,
      p_assoc_information8,
      p_assoc_information9,
      p_assoc_information10,
      p_assoc_information11,
      p_assoc_information12,
      p_assoc_information13,
      p_assoc_information14,
      p_assoc_information15,
      p_assoc_information16,
      p_assoc_information17,
      p_assoc_information18,
      p_assoc_information19,
      p_assoc_information20,
      l_association_type_id,
      l_subject_parent_id);

  --  Call the table handler to create a record in XLE_ASSOCIATIONS
  XLE_ASSOCIATION_PKG.Insert_Row (
      x_association_id           =>  x_association_id,
      p_association_type_id      =>  l_association_type_id,
      p_subject_id               =>  p_subject_id,
      p_object_id	         =>  p_object_id,
      p_subject_parent_id        =>  l_subject_parent_id,
      p_effective_from	         =>  p_effective_from,
      p_assoc_information_context =>  p_assoc_information_context,
      p_assoc_information1        =>  p_assoc_information1,
      p_assoc_information2        =>  p_assoc_information2,
      p_assoc_information3        =>  p_assoc_information3,
      p_assoc_information4        =>  p_assoc_information4,
      p_assoc_information5        =>  p_assoc_information5,
      p_assoc_information6        =>  p_assoc_information6,
      p_assoc_information7        =>  p_assoc_information7,
      p_assoc_information8        =>  p_assoc_information8,
      p_assoc_information9        =>  p_assoc_information9,
      p_assoc_information10       =>  p_assoc_information10,
      p_assoc_information11       =>  p_assoc_information11,
      p_assoc_information12       =>  p_assoc_information12,
      p_assoc_information13       =>  p_assoc_information13,
      p_assoc_information14       =>  p_assoc_information14,
      p_assoc_information15       =>  p_assoc_information15,
      p_assoc_information16       =>  p_assoc_information16,
      p_assoc_information17       =>  p_assoc_information17,
      p_assoc_information18       =>  p_assoc_information18,
      p_assoc_information19       =>  p_assoc_information19,
      p_assoc_information20       =>  p_assoc_information20,
      p_object_version_number =>  1);


  /*-----------------------------------------------+
  |   ========  END OF API BODY  ============   |
  +-----------------------------------------------*/

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
     COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1,
  -- get message info.
  FND_MSG_PUB.Count_And_Get (
      p_count    =>  x_msg_count,
      p_data     =>  x_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Create_Association_SP;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (
           p_count    =>  x_msg_count,
           p_data     =>  x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Create_Association_SP;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (
           p_count    =>  x_msg_count,
           p_data     =>  x_msg_data );

  WHEN OTHERS THEN
       ROLLBACK TO Create_Association_SP;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
       END IF;
       FND_MSG_PUB.Count_And_Get (
           p_count    =>  x_msg_count,
           p_data     =>  x_msg_data );

END Create_Association;


/*==========================================================================
 |  PROCEDURE
 |    Update_Association
 |
 |
 |  DESCRIPTION
 |    Updates a Legal Association 					                |
 |
 |  ARGUMENTS
 |      IN     :
 |               p_init_msg_list
 |               p_commit
 |               p_context
 |               p_subject_type
 |               p_subject_id
 |               p_object_type
 |               p_object_id
 |               p_effective_from
 |               p_assoc_information_context
 |               p_assoc_information1
 |               p_assoc_information2
 |               p_assoc_information3
 |               p_assoc_information4
 |               p_assoc_information5
 |               p_assoc_information6
 |               p_assoc_information7
 |               p_assoc_information8
 |               p_assoc_information9
 |               p_assoc_information10
 |               p_assoc_information11
 |               p_assoc_information12
 |               p_assoc_information13
 |               p_assoc_information14
 |               p_assoc_information15
 |               p_assoc_information16
 |               p_assoc_information17
 |               p_assoc_information18
 |               p_assoc_information19
 |               p_assoc_information20
 |
 |      OUT    :
 |               x_return_status
 |               x_msg_count
 |               x_msg_data
 |               x_association_id
 |
 |      IN/OUT :
 |
 |
 |  MODIFICATION HISTORY
 |
 |    18-MAR-2005   T.Tran          Created.
 |
 |===========================================================================*/


PROCEDURE Update_Association(

  --   *****  Standard API parameters *****
  p_init_msg_list             IN  VARCHAR2 := FND_API.G_TRUE,
  p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
  x_return_status             OUT NOCOPY VARCHAR2,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,

  --   *****  Legal Association information parameters *****
  p_association_id            IN  NUMBER   := NULL,
  p_context                   IN  VARCHAR2 := NULL,
  p_subject_type              IN  VARCHAR2 := NULL,
  p_subject_id                IN  NUMBER   := NULL,
  p_object_type               IN  VARCHAR2 := NULL,
  p_object_id                 IN  NUMBER   := NULL,
  p_effective_from            IN  DATE     := NULL,
  p_effective_to              IN  DATE     := NULL,
  p_assoc_information_context IN VARCHAR2  := NULL,
  p_assoc_information1        IN VARCHAR2  := NULL,
  p_assoc_information2        IN VARCHAR2  := NULL,
  p_assoc_information3        IN VARCHAR2  := NULL,
  p_assoc_information4        IN VARCHAR2  := NULL,
  p_assoc_information5        IN VARCHAR2  := NULL,
  p_assoc_information6        IN VARCHAR2  := NULL,
  p_assoc_information7        IN VARCHAR2  := NULL,
  p_assoc_information8        IN VARCHAR2  := NULL,
  p_assoc_information9        IN VARCHAR2  := NULL,
  p_assoc_information10       IN VARCHAR2  := NULL,
  p_assoc_information11       IN VARCHAR2  := NULL,
  p_assoc_information12       IN VARCHAR2  := NULL,
  p_assoc_information13       IN VARCHAR2  := NULL,
  p_assoc_information14       IN VARCHAR2  := NULL,
  p_assoc_information15       IN VARCHAR2  := NULL,
  p_assoc_information16       IN VARCHAR2  := NULL,
  p_assoc_information17       IN VARCHAR2  := NULL,
  p_assoc_information18       IN VARCHAR2  := NULL,
  p_assoc_information19       IN VARCHAR2  := NULL,
  p_assoc_information20       IN VARCHAR2  := NULL,
  p_object_version_number     IN OUT NOCOPY NUMBER)

IS

  l_api_name  CONSTANT  VARCHAR2(20) := 'Update_Association';
  l_association_id      NUMBER;
  l_association_type_id NUMBER;

BEGIN

  x_msg_count				:=	NULL;
  x_msg_data				:=	NULL;

  -- ****   Standard start of API savepoint  ****
  SAVEPOINT Update_Association_SP;

  -- ****  Initialize message list if p_init_msg_list is set to TRUE. ****
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- ****  Initialize return status to SUCCESS   *****
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  /*-----------------------------------------------+
  |   ========  START OF API BODY  ============   |
  +-----------------------------------------------*/

  -- ****    Validation of the Legal Associations Rules  ****

  l_association_id := p_association_id;

  XLE_ASSOC_VALIDATIONS_PVT.Validate_Update_Association (
      l_association_id,
      p_context,
      p_subject_type,
      p_subject_id,
      p_object_type,
      p_object_id,
      p_effective_from,
      p_effective_to,
      p_assoc_information_context,
      p_assoc_information1,
      p_assoc_information2,
      p_assoc_information3,
      p_assoc_information4,
      p_assoc_information5,
      p_assoc_information6,
      p_assoc_information7,
      p_assoc_information8,
      p_assoc_information9,
      p_assoc_information10,
      p_assoc_information11,
      p_assoc_information12,
      p_assoc_information13,
      p_assoc_information14,
      p_assoc_information15,
      p_assoc_information16,
      p_assoc_information17,
      p_assoc_information18,
      p_assoc_information19,
      p_assoc_information20 );


  --  ****    Call the table handler to lock the record in XLE_ASSOCIATIONS

  XLE_ASSOCIATION_PKG.Lock_Row (
      p_association_id        =>  l_association_id,
      p_object_version_number =>  p_object_version_number);

  p_object_version_number := NVL(p_object_version_number, 1) + 1;


  --  ****    Call the table handler to update a record in XLE_ASSOCIATIONS

  XLE_ASSOCIATION_PKG.Update_Row (
      p_association_id           =>  l_association_id,
      p_effective_from	         =>  p_effective_from,
      p_effective_to             =>  p_effective_to,
      p_assoc_information_context =>  p_assoc_information_context,
      p_assoc_information1        =>  p_assoc_information1,
      p_assoc_information2        =>  p_assoc_information2,
      p_assoc_information3        =>  p_assoc_information3,
      p_assoc_information4        =>  p_assoc_information4,
      p_assoc_information5        =>  p_assoc_information5,
      p_assoc_information6        =>  p_assoc_information6,
      p_assoc_information7        =>  p_assoc_information7,
      p_assoc_information8        =>  p_assoc_information8,
      p_assoc_information9        =>  p_assoc_information9,
      p_assoc_information10       =>  p_assoc_information10,
      p_assoc_information11       =>  p_assoc_information11,
      p_assoc_information12       =>  p_assoc_information12,
      p_assoc_information13       =>  p_assoc_information13,
      p_assoc_information14       =>  p_assoc_information14,
      p_assoc_information15       =>  p_assoc_information15,
      p_assoc_information16       =>  p_assoc_information16,
      p_assoc_information17       =>  p_assoc_information17,
      p_assoc_information18       =>  p_assoc_information18,
      p_assoc_information19       =>  p_assoc_information19,
      p_assoc_information20       =>  p_assoc_information20,
      p_object_version_number    =>  p_object_version_number,
      p_last_update_date         =>  XLE_UTILITY_PUB.LAST_UPDATE_DATE,
      p_last_updated_by          =>  XLE_UTILITY_PUB.LAST_UPDATED_BY,
      p_last_update_login        =>  XLE_UTILITY_PUB.LAST_UPDATE_LOGIN);



  /*-----------------------------------------------+
  |   ========  END OF API BODY  ============   |
  +-----------------------------------------------*/

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
     COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1,
  -- get message info.
  FND_MSG_PUB.Count_And_Get (
      p_count    =>  x_msg_count,
      p_data     =>  x_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Update_Association_SP;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (
           p_count    =>  x_msg_count,
           p_data     =>  x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Update_Association_SP;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (
           p_count    =>  x_msg_count,
           p_data     =>  x_msg_data );

  WHEN OTHERS THEN
       ROLLBACK TO Update_Association_SP;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
       END IF;
       FND_MSG_PUB.Count_And_Get (
           p_count    =>  x_msg_count,
           p_data     =>  x_msg_data );
END Update_Association;


END XLE_ASSOCIATIONS_PUB;


/
