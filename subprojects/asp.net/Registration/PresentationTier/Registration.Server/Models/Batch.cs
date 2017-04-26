﻿/* 
 * Uber API
 *
 * Move your app forward with the Uber API
 *
 * OpenAPI spec version: 1.0.0
 * 
 * Generated by: https://github.com/swagger-api/swagger-codegen.git
 */

using System;
using System.Linq;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Runtime.Serialization;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System.ComponentModel.DataAnnotations;
using CambridgeSoft.COE.Registration;
using CambridgeSoft.COE.Registration.Services.Types;

namespace IO.Swagger.Model
{
    /// <summary>
    /// Batch
    /// </summary>
    [DataContract]
    public partial class Batch : IEquatable<Batch>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="Batch" /> class.
        /// </summary>
        /// <param name="ID">ID.</param>
        /// <param name="TempBatchID">TempBatchID.</param>
        /// <param name="BatchNumber">BatchNumber.</param>
        /// <param name="FullRegNumber">FullRegNumber.</param>
        /// <param name="DateCreated">DateCreated.</param>
        /// <param name="PersonCreated">PersonCreated.</param>
        /// <param name="PersonRegistered">PersonRegistered.</param>
        /// <param name="PersonApproved">PersonApproved.</param>
        /// <param name="DateLastModified">DateLastModified.</param>
        /// <param name="Status">Status.</param>
        /// <param name="ProjectList">ProjectList.</param>
        /// <param name="PropertyList">PropertyList.</param>
        /// <param name="IdentifierList">IdentifierList.</param>
        /// <param name="BatchComponentList">BatchComponentList.</param>
        public Batch(int? ID = default(int?), int? TempBatchID = default(int?), int? BatchNumber = default(int?), string FullRegNumber = default(string), DateTime? DateCreated = default(DateTime?), int? PersonCreated = default(int?), int? PersonRegistered = default(int?), int? PersonApproved = default(int?), DateTime? DateLastModified = default(DateTime?), RegistryStatus Status = default(RegistryStatus), ProjectList ProjectList = default(ProjectList), PropertyList PropertyList = default(PropertyList), IdentifierList IdentifierList = default(IdentifierList), BatchComponentList BatchComponentList = default(BatchComponentList))
        {
            this.ID = ID;
            this.TempBatchID = TempBatchID;
            this.BatchNumber = BatchNumber;
            this.FullRegNumber = FullRegNumber;
            this.DateCreated = DateCreated;
            this.PersonCreated = PersonCreated;
            this.PersonRegistered = PersonRegistered;
            this.PersonApproved = PersonApproved;
            this.DateLastModified = DateLastModified;
            this.Status = Status;
            this.ProjectList = ProjectList;
            this.PropertyList = PropertyList;
            this.IdentifierList = IdentifierList;
            this.BatchComponentList = BatchComponentList;
        }

        /// <summary>
        /// Gets or Sets ID
        /// </summary>
        [DataMember(Name = "ID", EmitDefaultValue = false)]
        public int? ID { get; set; }
        /// <summary>
        /// Gets or Sets TempBatchID
        /// </summary>
        [DataMember(Name = "TempBatchID", EmitDefaultValue = false)]
        public int? TempBatchID { get; set; }
        /// <summary>
        /// Gets or Sets BatchNumber
        /// </summary>
        [DataMember(Name = "BatchNumber", EmitDefaultValue = false)]
        public int? BatchNumber { get; set; }
        /// <summary>
        /// Gets or Sets FullRegNumber
        /// </summary>
        [DataMember(Name = "FullRegNumber", EmitDefaultValue = false)]
        public string FullRegNumber { get; set; }
        /// <summary>
        /// Gets or Sets DateCreated
        /// </summary>
        [DataMember(Name = "DateCreated", EmitDefaultValue = false)]
        public DateTime? DateCreated { get; set; }
        /// <summary>
        /// Gets or Sets PersonCreated
        /// </summary>
        [DataMember(Name = "PersonCreated", EmitDefaultValue = false)]
        public int? PersonCreated { get; set; }
        /// <summary>
        /// Gets or Sets PersonRegistered
        /// </summary>
        [DataMember(Name = "PersonRegistered", EmitDefaultValue = false)]
        public int? PersonRegistered { get; set; }
        /// <summary>
        /// Gets or Sets PersonApproved
        /// </summary>
        [DataMember(Name = "PersonApproved", EmitDefaultValue = false)]
        public int? PersonApproved { get; set; }
        /// <summary>
        /// Gets or Sets DateLastModified
        /// </summary>
        [DataMember(Name = "DateLastModified", EmitDefaultValue = false)]
        public DateTime? DateLastModified { get; set; }
        /// <summary>
        /// Gets or Sets Status
        /// </summary>
        [DataMember(Name = "Status", EmitDefaultValue = false)]
        public RegistryStatus Status { get; set; }
        /// <summary>
        /// Gets or Sets ProjectList
        /// </summary>
        [DataMember(Name = "ProjectList", EmitDefaultValue = false)]
        public ProjectList ProjectList { get; set; }
        /// <summary>
        /// Gets or Sets PropertyList
        /// </summary>
        [DataMember(Name = "PropertyList", EmitDefaultValue = false)]
        public PropertyList PropertyList { get; set; }
        /// <summary>
        /// Gets or Sets IdentifierList
        /// </summary>
        [DataMember(Name = "IdentifierList", EmitDefaultValue = false)]
        public IdentifierList IdentifierList { get; set; }
        /// <summary>
        /// Gets or Sets BatchComponentList
        /// </summary>
        [DataMember(Name = "BatchComponentList", EmitDefaultValue = false)]
        public BatchComponentList BatchComponentList { get; set; }
        /// <summary>
        /// Returns the string presentation of the object
        /// </summary>
        /// <returns>String presentation of the object</returns>
        public override string ToString()
        {
            var sb = new StringBuilder();
            sb.Append("class Batch {\n");
            sb.Append("  ID: ").Append(ID).Append("\n");
            sb.Append("  TempBatchID: ").Append(TempBatchID).Append("\n");
            sb.Append("  BatchNumber: ").Append(BatchNumber).Append("\n");
            sb.Append("  FullRegNumber: ").Append(FullRegNumber).Append("\n");
            sb.Append("  DateCreated: ").Append(DateCreated).Append("\n");
            sb.Append("  PersonCreated: ").Append(PersonCreated).Append("\n");
            sb.Append("  PersonRegistered: ").Append(PersonRegistered).Append("\n");
            sb.Append("  PersonApproved: ").Append(PersonApproved).Append("\n");
            sb.Append("  DateLastModified: ").Append(DateLastModified).Append("\n");
            sb.Append("  Status: ").Append(Status).Append("\n");
            sb.Append("  ProjectList: ").Append(ProjectList).Append("\n");
            sb.Append("  PropertyList: ").Append(PropertyList).Append("\n");
            sb.Append("  IdentifierList: ").Append(IdentifierList).Append("\n");
            sb.Append("  BatchComponentList: ").Append(BatchComponentList).Append("\n");
            sb.Append("}\n");
            return sb.ToString();
        }

        /// <summary>
        /// Returns the JSON string presentation of the object
        /// </summary>
        /// <returns>JSON string presentation of the object</returns>
        public string ToJson()
        {
            return JsonConvert.SerializeObject(this, Formatting.Indented);
        }

        /// <summary>
        /// Returns true if objects are equal
        /// </summary>
        /// <param name="obj">Object to be compared</param>
        /// <returns>Boolean</returns>
        public override bool Equals(object obj)
        {
            // credit: http://stackoverflow.com/a/10454552/677735
            return this.Equals(obj as Batch);
        }

        /// <summary>
        /// Returns true if Batch instances are equal
        /// </summary>
        /// <param name="other">Instance of Batch to be compared</param>
        /// <returns>Boolean</returns>
        public bool Equals(Batch other)
        {
            // credit: http://stackoverflow.com/a/10454552/677735
            if (other == null)
                return false;

            return
                (
                    this.ID == other.ID ||
                    this.ID != null &&
                    this.ID.Equals(other.ID)
                ) &&
                (
                    this.TempBatchID == other.TempBatchID ||
                    this.TempBatchID != null &&
                    this.TempBatchID.Equals(other.TempBatchID)
                ) &&
                (
                    this.BatchNumber == other.BatchNumber ||
                    this.BatchNumber != null &&
                    this.BatchNumber.Equals(other.BatchNumber)
                ) &&
                (
                    this.FullRegNumber == other.FullRegNumber ||
                    this.FullRegNumber != null &&
                    this.FullRegNumber.Equals(other.FullRegNumber)
                ) &&
                (
                    this.DateCreated == other.DateCreated ||
                    this.DateCreated != null &&
                    this.DateCreated.Equals(other.DateCreated)
                ) &&
                (
                    this.PersonCreated == other.PersonCreated ||
                    this.PersonCreated != null &&
                    this.PersonCreated.Equals(other.PersonCreated)
                ) &&
                (
                    this.PersonRegistered == other.PersonRegistered ||
                    this.PersonRegistered != null &&
                    this.PersonRegistered.Equals(other.PersonRegistered)
                ) &&
                (
                    this.PersonApproved == other.PersonApproved ||
                    this.PersonApproved != null &&
                    this.PersonApproved.Equals(other.PersonApproved)
                ) &&
                (
                    this.DateLastModified == other.DateLastModified ||
                    this.DateLastModified != null &&
                    this.DateLastModified.Equals(other.DateLastModified)
                ) &&
                (
                    this.Status == other.Status ||
                    this.Status != null &&
                    this.Status.Equals(other.Status)
                ) &&
                (
                    this.ProjectList == other.ProjectList ||
                    this.ProjectList != null &&
                    this.ProjectList.Equals(other.ProjectList)
                ) &&
                (
                    this.PropertyList == other.PropertyList ||
                    this.PropertyList != null &&
                    this.PropertyList.Equals(other.PropertyList)
                ) &&
                (
                    this.IdentifierList == other.IdentifierList ||
                    this.IdentifierList != null &&
                    this.IdentifierList.Equals(other.IdentifierList)
                ) &&
                (
                    this.BatchComponentList == other.BatchComponentList ||
                    this.BatchComponentList != null &&
                    this.BatchComponentList.Equals(other.BatchComponentList)
                );
        }

        /// <summary>
        /// Gets the hash code
        /// </summary>
        /// <returns>Hash code</returns>
        public override int GetHashCode()
        {
            // credit: http://stackoverflow.com/a/263416/677735
            unchecked // Overflow is fine, just wrap
            {
                int hash = 41;
                // Suitable nullity checks etc, of course :)
                if (this.ID != null)
                    hash = hash * 59 + this.ID.GetHashCode();
                if (this.TempBatchID != null)
                    hash = hash * 59 + this.TempBatchID.GetHashCode();
                if (this.BatchNumber != null)
                    hash = hash * 59 + this.BatchNumber.GetHashCode();
                if (this.FullRegNumber != null)
                    hash = hash * 59 + this.FullRegNumber.GetHashCode();
                if (this.DateCreated != null)
                    hash = hash * 59 + this.DateCreated.GetHashCode();
                if (this.PersonCreated != null)
                    hash = hash * 59 + this.PersonCreated.GetHashCode();
                if (this.PersonRegistered != null)
                    hash = hash * 59 + this.PersonRegistered.GetHashCode();
                if (this.PersonApproved != null)
                    hash = hash * 59 + this.PersonApproved.GetHashCode();
                if (this.DateLastModified != null)
                    hash = hash * 59 + this.DateLastModified.GetHashCode();
                if (this.Status != null)
                    hash = hash * 59 + this.Status.GetHashCode();
                if (this.ProjectList != null)
                    hash = hash * 59 + this.ProjectList.GetHashCode();
                if (this.PropertyList != null)
                    hash = hash * 59 + this.PropertyList.GetHashCode();
                if (this.IdentifierList != null)
                    hash = hash * 59 + this.IdentifierList.GetHashCode();
                if (this.BatchComponentList != null)
                    hash = hash * 59 + this.BatchComponentList.GetHashCode();
                return hash;
            }
        }
    }

}
