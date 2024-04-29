--------------------------------------------------------
--  DDL for Package Body IBE_DSP_HIERARCHY_SETUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_DSP_HIERARCHY_SETUP_PUB" AS
/* $Header: IBEPCHSB.pls 120.5 2006/01/11 15:54:45 abhandar ship $ */
  --
  --
  -- Start of Comments
  --
  -- NAME
  --   IBE_DSP_HIERARCHY_SETUP_PUB
  --
  -- PURPOSE
  --   Private API for saving, retrieving and updating sections.
  --
  -- NOTES
  --   This is a pulicly accessible pacakge.  It should be used by all
  --   sources for saving, retrieving and updating personalized queries
  -- within the personalization framework.
  --

  -- HISTORY
  --   09/05/00           VPALAIYA         Created
  --   09/17/05           ABHANDAR         Modified
  -- **************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):='IBE_DSP_HIERAHCY_SETUP_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12):='IBEPCHSB.pls';

--
-- Start of comments
--  API name    : Create_Hierarchy_Section
--  Type        : Public
--  Pre-reqs    : None.
--  Function    : Creates a section in the catalog hierarchy
--  Parameters  :
--    IN        : p_api_version     IN NUMBER    Required
--    Version   : Current version    1.0
--                Previous version   1.0
--                Initial version    1.0
-- End of comments
--
--
-- Start of comments
--  API name    : Create_Hierarchy_Section
--  Type        : Public
--  Pre-reqs    : None.
--  Function    : Creates a section in the catalog hierarchy
--  Parameters  :
--    IN        : p_api_version     IN NUMBER    Required
--    Version   : Current version    1.0
--                Previous version   1.0
--                Initial version    1.0
-- End of comments
--

PROCEDURE Create_Section(
   p_api_version                   	IN NUMBER,
   p_init_msg_list                 	IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                        	IN VARCHAR2 := FND_API.G_FALSE,
   x_return_status 	                OUT NOCOPY VARCHAR2,
   x_msg_count                     	OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2,
   p_hierachy_section_rec           IN  SECTION_REC_TYPE,
   x_section_id                     OUT NOCOPY NUMBER)
IS
  l_api_name          CONSTANT VARCHAR2(30):='Create_Hierarchy_Section';
  l_api_version       CONSTANT NUMBER := 1.0;
  l_debug             VARCHAR2(1);

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT  CREATE_HIERARCHY_SECTION_PUB;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
  END IF;
  l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

   -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF (l_debug='Y') THEN
     IBE_UTIL.debug('parameters: parent id=' ||p_hierachy_section_rec.parent_section_id||
    ' start_date='||p_hierachy_section_rec.start_date_active ||
    ' type_code='||p_hierachy_section_rec.section_type_code||
    ' status_code=' ||p_hierachy_section_rec.status_code ||
    ' display_name='||p_hierachy_section_rec.display_name);
   END IF;

  IBE_DSP_HIERARCHY_SETUP_PVT.Create_Hierarchy_Section
    (
    p_api_version                    => p_api_version,
    p_init_msg_list                  => p_init_msg_list,
    p_commit                         => p_commit,
    p_validation_level               => FND_API.G_VALID_LEVEL_FULL,
    p_parent_section_id              => p_hierachy_section_rec.parent_section_id,
    p_parent_section_access_name     => p_hierachy_section_rec.parent_section_access_name,
    p_access_name                    => p_hierachy_section_rec.access_name,
    p_start_date_active              => p_hierachy_section_rec.start_date_active,
    p_end_date_active                => p_hierachy_section_rec.end_date_active,
    p_section_type_code              => p_hierachy_section_rec.section_type_code,
    p_status_code                    => p_hierachy_section_rec.status_code,
   --- p_display_context_id             => p_hierachy_section_rec.display_context_id,
   --- p_deliverable_id                 => p_hierachy_section_rec.deliverable_id,
    p_display_name                   => p_hierachy_section_rec.display_name,
    p_description                    => p_hierachy_section_rec.description,
    p_long_description               => p_hierachy_section_rec.long_description,
    p_keywords                       => p_hierachy_section_rec.keywords,
    p_attribute_category             => p_hierachy_section_rec.attribute_category,
    p_attribute1                     => p_hierachy_section_rec.attribute1,
    p_attribute2                     => p_hierachy_section_rec.attribute2,
    p_attribute3                     => p_hierachy_section_rec.attribute3,
    p_attribute4                     => p_hierachy_section_rec.attribute4,
    p_attribute5                     => p_hierachy_section_rec.attribute5,
    p_attribute6                     => p_hierachy_section_rec.attribute6,
    p_attribute7                     => p_hierachy_section_rec.attribute7,
    p_attribute8                     => p_hierachy_section_rec.attribute8,
    p_attribute9                     => p_hierachy_section_rec.attribute9,
    p_attribute10                    => p_hierachy_section_rec.attribute10,
    p_attribute11                    => p_hierachy_section_rec.attribute11,
    p_attribute12                    => p_hierachy_section_rec.attribute12,
    p_attribute13                    => p_hierachy_section_rec.attribute13,
    p_attribute14                    => p_hierachy_section_rec.attribute14,
    p_attribute15                    => p_hierachy_section_rec.attribute15,
    x_section_id                     => x_section_id,
    x_return_status                  => x_return_status,
    x_msg_count                      => x_msg_count,
    x_msg_data                       => x_msg_data
    );
  --
  -- End of main API body.
    IF  (l_debug='Y') AND ( x_return_status <> FND_API.G_RET_STS_ERROR) THEN
        FOR i in 1..x_msg_count loop
	       IBE_UTIL.debug(FND_MSG_PUB.get(i,FND_API.G_FALSE));
	    END LOOP;
    END IF;

  -- Standard check of p_commit.
  IF (FND_API.To_Boolean(p_commit)) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count   =>      x_msg_count,
                            p_data    =>      x_msg_data,
                            p_encoded =>      'F');

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_HIERARCHY_SECTION_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_HIERARCHY_SECTION_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_HIERARCHY_SECTION_PUB;
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Create_Section;


PROCEDURE Create_Section_Items(
   p_api_version                    	IN NUMBER,
   p_init_msg_list                    	IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         	IN VARCHAR2 := FND_API.G_FALSE,
   x_return_status                  	OUT NOCOPY VARCHAR2,
   x_msg_count                      	OUT NOCOPY NUMBER,
   x_msg_data                       	OUT NOCOPY VARCHAR2,
   p_section_id                        	IN NUMBER,
   p_section_item_tbl               	IN SECTION_ITEM_TBL_TYPE,
   x_section_item_out_tbl            	OUT NOCOPY SECTION_ITEM_OUT_TBL_TYPE)
  IS

  l_api_name          CONSTANT VARCHAR2(30) := 'Associate_Items_To_Section';
  l_api_version       CONSTANT NUMBER   := 1.0;


BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  ASSOCIATE_ITEMS_TO_SECTION_PUB;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API Body start

  -- call the private API for the association
  IBE_DSP_HIERARCHY_SETUP_PVT.Associate_Items_To_Section(
   p_api_version                    => p_api_version,
   p_init_msg_list                  => p_init_msg_list,
   p_commit                         => p_commit,
   p_validation_level               => FND_API.G_VALID_LEVEL_FULL,
   x_return_status                  => x_return_status,
   x_msg_count                      => x_msg_count,
   x_msg_data                       => x_msg_data,
   p_section_id                     => p_section_id,
   p_section_item_tbl               => p_section_item_tbl,
   x_section_item_out_tbl           => x_section_item_out_tbl);

   -- End of main API body.

  -- Standard check of p_commit.
  IF (FND_API.To_Boolean(p_commit)) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count   =>      x_msg_count,
                            p_data    =>      x_msg_data,
                            p_encoded =>      'F');

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO ASSOCIATE_ITEMS_TO_SECTION_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO ASSOCIATE_ITEMS_TO_SECTION_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO ASSOCIATE_ITEMS_TO_SECTION_PUB;
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

 END Create_Section_Items;

/* Procedure to Associate Content to Section and Items ; And templates for Items */
PROCEDURE Create_Object_Logical_Content (
  p_api_version        		    IN  NUMBER,
  p_init_msg_list       		IN  VARCHAR2 := FND_API.g_false,
  p_commit              		IN  VARCHAR2 := FND_API.g_false,
  p_object_type			        IN  VARCHAR2,
  p_obj_lgl_ctnt_tbl		    IN  OBJ_LGL_CTNT_TBL_TYPE,
  x_return_status       		OUT NOCOPY VARCHAR2,
  x_msg_count           		OUT NOCOPY  NUMBER,
  x_msg_data            		OUT NOCOPY  VARCHAR2,
  x_obj_lgl_ctnt_out_tbl        OUT NOCOPY OBJ_LGL_CTNT_OUT_TBL_TYPE)

IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Associate_Logical_Content';
  l_api_version             CONSTANT NUMBER   := 1.0;
  l_obj_rec_i               IBE_LogicalContent_GRP.obj_lgl_ctnt_rec_type;
  l_obj_tbl_i               IBE_LogicalContent_GRP.obj_lgl_ctnt_tbl_type;
  l_debug                   VARCHAR2(1);
  l_obj_tbl_out             IBE_DSP_HIERARCHY_SETUP_PUB.OBJ_LGL_CTNT_OUT_TBL_TYPE;
  l_overall_return_status   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT ASSOCIATE_LOGICAL_CONTENT_PUB;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
  END IF;

  l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

  IF (l_debug = 'Y') THEN
        IBE_UTIL.debug('start of Associate_Logical_Content');
  END If;

  -- API Body start

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FOR i in p_obj_lgl_ctnt_tbl.FIRST..p_obj_lgl_ctnt_tbl.COUNT() LOOP

        l_obj_rec_i.OBJ_lgl_ctnt_id       := NULL; -- to insert a new one
        l_obj_rec_i.Object_Version_Number := NULL; -- internally set as 1
        l_obj_rec_i.Object_id             := p_obj_lgl_ctnt_tbl(i).object_id;
        l_obj_rec_i.Context_id            := p_obj_lgl_ctnt_tbl(i).context_id;
        l_obj_rec_i.deliverable_id        := p_obj_lgl_ctnt_tbl(i).deliverable_id;
        l_obj_rec_i.obj_lgl_ctnt_delete   := FND_API.g_false;

        -- Now call the API to do the association.
        -- Always passing a collection of 1 element
        l_obj_tbl_i(1) := l_obj_rec_i;

        -- Call private API to associate the items to the section
        IBE_LogicalContent_GRP.save_delete_lgl_ctnt(
            p_api_version         => p_api_version,
            p_init_msg_list       => p_init_msg_list,
            p_commit              => p_commit,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            p_object_type_code	  => p_object_type,
            p_lgl_ctnt_tbl	      => l_obj_tbl_i);

        l_obj_tbl_out(i).object_id       := l_obj_tbl_i(1).OBJECT_ID;
        l_obj_tbl_out(i).context_id      := l_obj_tbl_i(1).CONTEXT_ID;
        l_obj_tbl_out(i).deliverable_id  := l_obj_tbl_i(1).DELIVERABLE_ID;
        l_obj_tbl_out(i).x_return_status := x_return_status;

        -- derive the API overall status
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            l_overall_return_status:= FND_API.G_RET_STS_ERROR;
            IF (l_debug = 'Y') THEN
	            FOR i in 1..x_msg_count loop
	              IBE_UTIL.debug(FND_MSG_PUB.get(i,FND_API.G_FALSE));
	            END LOOP;
              END IF;
         END IF;
  END LOOP;

  x_obj_lgl_ctnt_out_tbl :=  l_obj_tbl_out;

  -- set the x_return status to the API overall status
  x_return_status:= l_overall_return_status;

  if(l_debug='Y') then
     IBE_UTIL.debug('API overall status='||l_overall_return_status);
  end if;

  -- End of main API body.

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count   =>      x_msg_count,
                            p_data    =>      x_msg_data,
                            p_encoded =>      'F');

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO ASSOCIATE_LOGICAL_CONTENT_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO ASSOCIATE_LOGICAL_CONTENT_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO ASSOCIATE_LOGICAL_CONTENT_PUB;
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

 END Create_Object_Logical_Content;

END IBE_DSP_HIERARCHY_SETUP_PUB;

/
