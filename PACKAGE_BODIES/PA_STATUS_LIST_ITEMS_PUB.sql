--------------------------------------------------------
--  DDL for Package Body PA_STATUS_LIST_ITEMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_STATUS_LIST_ITEMS_PUB" AS
 /* $Header: PACISIPB.pls 120.1 2005/08/19 16:18:08 mwasowic noship $ */

-- --------------------------------------------------------------------------
--  PROCEDURE
--      Insert_Row
--  PURPOSE
--      This procedure inserts a row into the pa_status_list_items table.
--
--  HISTORY
--      28-JAN-04		svenketa		Created
--

PROCEDURE CreateStatusListItem (
 P_RECORD_VERSION_NUMBER        IN	   NUMBER,
 PX_STATUS_LIST_ITEM_ID         IN OUT	   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 P_STATUS_LIST_ID               IN	   NUMBER,
 P_PROJECT_STATUS_CODE          IN	   VARCHAR2,
 P_LAST_UPDATE_DATE             IN         DATE ,
 P_LAST_UPDATED_BY              IN         NUMBER ,
 P_CREATION_DATE                IN         DATE ,
 P_CREATED_BY                   IN         NUMBER ,
 P_LAST_UPDATE_LOGIN            IN         NUMBER ,
 X_RETURN_STATUS                OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT                    OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA                     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

BEGIN

  -- Initialize the Error Stack
        PA_DEBUG.init_err_stack('PA_STATUS_LIST_ITEMS_PUB.CreateStatusListItem');
        x_msg_count := 0;
        x_msg_data  := NULL;

  -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        PA_STATUS_LIST_ITEMS_PVT.CreateStatusListItem
        (
	 P_RECORD_VERSION_NUMBER=>	P_RECORD_VERSION_NUMBER,
	 PX_STATUS_LIST_ITEM_ID  =>	PX_STATUS_LIST_ITEM_ID,
	 P_STATUS_LIST_ID       =>      P_STATUS_LIST_ID,
	 P_PROJECT_STATUS_CODE  =>	P_PROJECT_STATUS_CODE,
	 P_LAST_UPDATE_DATE     =>	P_LAST_UPDATE_DATE,
	 P_LAST_UPDATED_BY      =>	P_LAST_UPDATED_BY,
	 P_CREATION_DATE        =>	P_CREATION_DATE,
	 P_CREATED_BY           =>	P_CREATED_BY,
	 P_LAST_UPDATE_LOGIN    =>	P_LAST_UPDATE_LOGIN,
	 X_RETURN_STATUS        =>	X_RETURN_STATUS,
	 X_MSG_COUNT            =>	X_MSG_COUNT,
	 X_MSG_DATA             =>	X_MSG_DATA
        );
  -- Reset the Error Stack
        PA_DEBUG.reset_err_stack;

        EXCEPTION
        WHEN OTHERS THEN
          x_msg_count := 1;
          x_msg_data  := substr(SQLERRM,1,240);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.add_exc_msg
          (p_pkg_name => 'PA_STATUS_LIST_ITEMS_PUB'
           , p_procedure_name => PA_DEBUG.G_Err_Stack
           , p_error_text => substr(SQLERRM,1,240));
           RETURN;

END CreateStatusListItem;



-- -------------------------------------------------------------------------
--  PROCEDURE
--      Update_Row
--  PURPOSE
--      This procedure updates a row in the PA_STATUS_LIST_ITEMS table.
--
--  HISTORY
--      16-JAN-04		svenketa		Created

PROCEDURE UpdateStatusListItem (
 P_RECORD_VERSION_NUMBER        IN	   NUMBER,
 P_STATUS_LIST_ITEM_ID         IN 	   NUMBER,
 P_STATUS_LIST_ID               IN	   NUMBER,
 P_PROJECT_STATUS_CODE          IN	   VARCHAR2,
 P_LAST_UPDATE_DATE             IN         DATE ,
 P_LAST_UPDATED_BY              IN         NUMBER ,
 P_CREATION_DATE                IN         DATE ,
 P_CREATED_BY                   IN         NUMBER ,
 P_LAST_UPDATE_LOGIN            IN         NUMBER ,
 X_RETURN_STATUS                OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT                    OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA                     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
l_rec_version_no NUMBER;
BEGIN

  -- Initialize the Error Stack
        PA_DEBUG.init_err_stack('PA_STATUS_LIST_ITEMS_PUB.UpdateStatusListItem');
        x_msg_count := 0;
        x_msg_data  := NULL;

  -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;


        PA_STATUS_LIST_ITEMS_PVT.UpdateStatusListItem
        (
	 P_RECORD_VERSION_NUMBER=>	P_RECORD_VERSION_NUMBER,
	 P_STATUS_LIST_ITEM_ID  =>	P_STATUS_LIST_ITEM_ID,
	 P_STATUS_LIST_ID       =>      P_STATUS_LIST_ID,
	 P_PROJECT_STATUS_CODE  =>	P_PROJECT_STATUS_CODE,
	 P_LAST_UPDATE_DATE     =>	P_LAST_UPDATE_DATE,
	 P_LAST_UPDATED_BY      =>	P_LAST_UPDATED_BY,
	 P_CREATION_DATE        =>	P_CREATION_DATE,
	 P_CREATED_BY           =>	P_CREATED_BY,
	 P_LAST_UPDATE_LOGIN    =>	P_LAST_UPDATE_LOGIN,
	 X_RETURN_STATUS        =>	X_RETURN_STATUS,
	 X_MSG_COUNT            =>	X_MSG_COUNT,
	 X_MSG_DATA             =>	X_MSG_DATA
        );

  -- Reset the Error Stack
        PA_DEBUG.reset_err_stack;

        EXCEPTION
        WHEN OTHERS THEN
          x_msg_count := 1;
          x_msg_data  := substr(SQLERRM,1,240);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.add_exc_msg
          (p_pkg_name => 'PA_STATUS_LIST_ITEMS_PUB'
           , p_procedure_name => PA_DEBUG.G_Err_Stack
           , p_error_text => substr(SQLERRM,1,240));
           RETURN;

END UpdateStatusListItem;


-- ---------------------------------------------------------------------
--  PROCEDURE
--      Delete_Row
--  PURPOSE
--      This procedure deletes a row in the PA_STATUS_LIST_ITEMS table.
--
--      If a row is deleted, this API returns (S)uccess for the
--      x_return_status.
--
--  HISTORY
--      16-JAN-04		svenketa		Created
--

PROCEDURE DeleteStatusListItem (
 P_STATUS_LIST_ITEM_ID         IN         NUMBER,
 P_RECORD_VERSION_NUMBER        IN	   NUMBER,
 X_RETURN_STATUS                OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT                    OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA                     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
BEGIN


  -- Initialize the Error Stack
        PA_DEBUG.init_err_stack('PA_STATUS_LIST_ITEMS_PUB.DeleteStatusListItem');
        x_msg_count := 0;
        x_msg_data  := NULL;

  -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Delete Role
        PA_STATUS_LIST_ITEMS_PVT.DeleteStatusListItem
        ( P_STATUS_LIST_ITEM_ID =>  P_STATUS_LIST_ITEM_ID,
	  P_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
          X_RETURN_STATUS  => X_RETURN_STATUS,
          X_MSG_COUNT      => X_MSG_COUNT,
          X_MSG_DATA       => X_MSG_DATA
        );

  -- Reset the Error Stack
        PA_DEBUG.reset_err_stack;

        EXCEPTION
        WHEN OTHERS THEN
          x_msg_count := 1;
          x_msg_data  := substr(SQLERRM,1,240);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.add_exc_msg
          (p_pkg_name => 'PA_STATUS_LIST_ITEMS_PUB'
           , p_procedure_name => PA_DEBUG.G_Err_Stack
           , p_error_text => substr(SQLERRM,1,240));
           RETURN;

END DeleteStatusListItem;


END PA_STATUS_LIST_ITEMS_pub;

/
