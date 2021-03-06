;;;; src/make-qvm.lisp
;;;;
;;;; Author: Nikolas Tezak
;;;;         appleby

(in-package #:qvm-app-ng)

(defun make-requested-allocation-descriptor (allocation-method length)
  (ecase allocation-method
    (native  (make-instance 'qvm:lisp-allocation :length length))
    (foreign (make-instance 'qvm:c-allocation :length length))))

(defgeneric make-requested-qvm (simulation-method allocation-method num-qubits
                                gate-noise measurement-noise)
  (:documentation "Create and return a QVM instance of the requested type."))

(defmethod make-requested-qvm ((simulation-method (eql 'pure-state))
                               allocation-method
                               num-qubits
                               (gate-noise null)
                               (measurement-noise null))
  (qvm:make-qvm num-qubits :allocation (make-requested-allocation-descriptor
                                        allocation-method
                                        (expt 2 num-qubits))))

(defmethod make-requested-qvm ((simulation-method (eql 'pure-state))
                               allocation-method
                               num-qubits
                               gate-noise
                               measurement-noise)
  (let ((gate-noise (or gate-noise (load-time-value '(0.0 0.0 0.0))))
        (measurement-noise (or measurement-noise (load-time-value '(0.0 0.0 0.0)))))
    (make-instance 'qvm:depolarizing-qvm
                   :number-of-qubits num-qubits
                   :state (qvm::make-pure-state num-qubits
                                                :allocation (make-requested-allocation-descriptor
                                                             allocation-method
                                                             (expt 2 num-qubits)))
                   :x (first gate-noise)
                   :y (second gate-noise)
                   :z (third gate-noise)
                   :measure-x (first measurement-noise)
                   :measure-y (second measurement-noise)
                   :measure-z (third measurement-noise))))

(defmethod make-requested-qvm ((simulation-method (eql 'full-density-matrix))
                               allocation-method
                               num-qubits
                               (gate-noise null)
                               (measurement-noise null))
  (qvm:make-density-qvm num-qubits :allocation (make-requested-allocation-descriptor
                                                allocation-method
                                                (expt 2 (* 2 num-qubits)))))
