//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace PerkinElmer.CBOE.Registration.Client.Model
{
    using System;
    using System.Collections.Generic;
    
    public partial class BATCH_IDENTIFIER
    {
        public int ID { get; set; }
        public Nullable<int> TYPE { get; set; }
        public Nullable<int> BATCHID { get; set; }
        public string VALUE { get; set; }
        public Nullable<int> ORDERINDEX { get; set; }
    
        public virtual BATCH BATCH { get; set; }
    }
}
