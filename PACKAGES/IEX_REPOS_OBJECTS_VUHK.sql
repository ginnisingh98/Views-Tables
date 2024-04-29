--------------------------------------------------------
--  DDL for Package IEX_REPOS_OBJECTS_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_REPOS_OBJECTS_VUHK" AUTHID CURRENT_USER AS
/* $Header: iexvreps.pls 120.1 2005/06/29 09:35:34 lkkumar noship $ */



 subtype repv_rec_type is iex_rep_pvt.repv_rec_type;
 subtype repv_tbl_type is iex_rep_pvt.repv_tbl_type;

 PROCEDURE insert_repos_objects_pre(
     p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_msg_data                  OUT  NOCOPY VARCHAR2
    ,x_msg_count                 OUT  NOCOPY NUMBER
    ,x_return_status             OUT  NOCOPY VARCHAR2
    ,p_repv_rec                  IN  repv_rec_type
    ,x_repv_rec                  OUT NOCOPY  repv_rec_type) ;


 PROCEDURE insert_repos_objects_pre(
     p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_msg_data                  OUT  NOCOPY VARCHAR2
    ,x_msg_count                 OUT  NOCOPY NUMBER
    ,x_return_status             OUT  NOCOPY VARCHAR2
    ,p_repv_tbl                  IN  repv_tbl_type
    ,x_repv_tbl                  OUT NOCOPY  repv_tbl_type) ;


 PROCEDURE insert_repos_objects_post(
     p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_msg_data                  OUT  NOCOPY VARCHAR2
    ,x_msg_count                 OUT  NOCOPY NUMBER
    ,x_return_status             OUT  NOCOPY VARCHAR2
    ,p_repv_rec                  IN  repv_rec_type) ;


 PROCEDURE insert_repos_objects_post(
     p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_msg_data                  OUT  NOCOPY VARCHAR2
    ,x_msg_count                 OUT  NOCOPY NUMBER
    ,x_return_status             OUT  NOCOPY VARCHAR2
    ,p_repv_tbl                  IN  repv_tbl_type) ;


 PROCEDURE validate_repos_objects_pre(
     p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_msg_data                  OUT  NOCOPY VARCHAR2
    ,x_msg_count                 OUT  NOCOPY NUMBER
    ,x_return_status             OUT  NOCOPY VARCHAR2
    ,p_repv_rec                  IN  repv_rec_type
    ,x_repv_rec                  OUT NOCOPY  repv_rec_type) ;


 PROCEDURE validate_repos_objects_pre(
     p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_msg_data                  OUT  NOCOPY VARCHAR2
    ,x_msg_count                 OUT  NOCOPY NUMBER
    ,x_return_status             OUT  NOCOPY VARCHAR2
    ,p_repv_tbl                  IN  repv_tbl_type
    ,x_repv_tbl                  OUT NOCOPY  repv_tbl_type) ;


 PROCEDURE validate_repos_objects_post(
     p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_msg_data                  OUT  NOCOPY VARCHAR2
    ,x_msg_count                 OUT  NOCOPY NUMBER
    ,x_return_status             OUT  NOCOPY VARCHAR2
    ,p_repv_rec                  IN  repv_rec_type) ;


 PROCEDURE validate_repos_objects_post(
     p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_msg_data                  OUT  NOCOPY VARCHAR2
    ,x_msg_count                 OUT  NOCOPY NUMBER
    ,x_return_status             OUT  NOCOPY VARCHAR2
    ,p_repv_tbl                  IN  repv_tbl_type) ;


 PROCEDURE update_repos_objects_pre(
     p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_msg_data                  OUT  NOCOPY VARCHAR2
    ,x_msg_count                 OUT  NOCOPY NUMBER
    ,x_return_status             OUT  NOCOPY VARCHAR2
    ,p_repv_rec                  IN  repv_rec_type
    ,x_repv_rec                  OUT NOCOPY  repv_rec_type) ;


 PROCEDURE update_repos_objects_pre(
     p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_msg_data                  OUT  NOCOPY VARCHAR2
    ,x_msg_count                 OUT  NOCOPY NUMBER
    ,x_return_status             OUT  NOCOPY VARCHAR2
    ,p_repv_tbl                  IN  repv_tbl_type
    ,x_repv_tbl                  OUT NOCOPY  repv_tbl_type) ;


 PROCEDURE update_repos_objects_post(
     p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_msg_data                  OUT  NOCOPY VARCHAR2
    ,x_msg_count                 OUT  NOCOPY NUMBER
    ,x_return_status             OUT  NOCOPY VARCHAR2
    ,p_repv_rec                  IN  repv_rec_type) ;


 PROCEDURE update_repos_objects_post(
     p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_msg_data                  OUT  NOCOPY VARCHAR2
    ,x_msg_count                 OUT  NOCOPY NUMBER
    ,x_return_status             OUT  NOCOPY VARCHAR2
    ,p_repv_tbl                  IN  repv_tbl_type) ;


 PROCEDURE delete_repos_objects_pre(
     p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_msg_data                  OUT  NOCOPY VARCHAR2
    ,x_msg_count                 OUT  NOCOPY NUMBER
    ,x_return_status             OUT  NOCOPY VARCHAR2
    ,p_repv_rec                  IN  repv_rec_type
    ,x_repv_rec                  OUT NOCOPY  repv_rec_type) ;


 PROCEDURE delete_repos_objects_pre(
     p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_msg_data                  OUT  NOCOPY VARCHAR2
    ,x_msg_count                 OUT  NOCOPY NUMBER
    ,x_return_status             OUT  NOCOPY VARCHAR2
    ,p_repv_tbl                  IN  repv_tbl_type
    ,x_repv_tbl                  OUT NOCOPY  repv_tbl_type) ;


 PROCEDURE delete_repos_objects_post(
     p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_msg_data                  OUT  NOCOPY VARCHAR2
    ,x_msg_count                 OUT  NOCOPY NUMBER
    ,x_return_status             OUT  NOCOPY VARCHAR2
    ,p_repv_rec                  IN  repv_rec_type) ;


 PROCEDURE delete_repos_objects_post(
     p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_msg_data                  OUT  NOCOPY VARCHAR2
    ,x_msg_count                 OUT  NOCOPY NUMBER
    ,x_return_status             OUT  NOCOPY VARCHAR2
    ,p_repv_tbl                  IN  repv_tbl_type) ;

END iex_repos_objects_vuhk;


 

/
