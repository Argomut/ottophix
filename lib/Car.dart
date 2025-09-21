class Car {
  final int carId;
  final String carMake;
  final String carModel;
  final int carYear;
  final String vinNumber;
  final String licencePlate;
  final String color;
  final String customerId;

  Car({
    required this.carId,
    required this.carMake,
    required this.carModel,
    required this.carYear,
    required this.vinNumber,
    required this.licencePlate,
    required this.color,
    required this.customerId,
  });

  factory Car.fromJson(Map<String, dynamic> map) {
    return Car(
      carId: map['car_id'],
      carMake: map['car_make'],
      carModel: map['car_model'],
      carYear: map['car_year'],
      vinNumber: map['vin_number'],
      licencePlate: map['licence_plate'],
      color: map['color'],
      customerId: map['customer_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'car_id': carId,
      'car_make': carMake,
      'car_model': carModel,
      'car_year': carYear,
      'vin_number': vinNumber,
      'licence_plate': licencePlate,
      'color': color,
      'customer_id': customerId,
    };
  }
}
