﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace PerkinElmer.COE.Inventory.DAL
{
    using System;
    using System.Data.Entity;
    using System.Data.Entity.Infrastructure;
    
    public partial class InventoryDB : DbContext
    {
        public InventoryDB()
            : base("name=InventoryDB")
        {
        }
    
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            throw new UnintentionalCodeFirstException();
        }
    
        public virtual DbSet<INV_COMPOUNDS> INV_COMPOUNDS { get; set; }
        public virtual DbSet<INV_CONTAINER_STATUS> INV_CONTAINER_STATUS { get; set; }
        public virtual DbSet<INV_CONTAINER_TYPES> INV_CONTAINER_TYPES { get; set; }
        public virtual DbSet<INV_CONTAINERS> INV_CONTAINERS { get; set; }
        public virtual DbSet<INV_LOCATION_TYPES> INV_LOCATION_TYPES { get; set; }
        public virtual DbSet<INV_LOCATIONS> INV_LOCATIONS { get; set; }
        public virtual DbSet<INV_SUPPLIERS> INV_SUPPLIERS { get; set; }
        public virtual DbSet<INV_UNITS> INV_UNITS { get; set; }
        public virtual DbSet<INV_CUSTOM_CPD_FIELD_VALUES> INV_CUSTOM_CPD_FIELD_VALUES { get; set; }
        public virtual DbSet<INV_CUSTOM_FIELD_GROUPS> INV_CUSTOM_FIELD_GROUPS { get; set; }
        public virtual DbSet<INV_CUSTOM_FIELDS> INV_CUSTOM_FIELDS { get; set; }
    }
}
